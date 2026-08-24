pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Network state.
//
// Previously this ran two `bash -c` wrappers around `iwctl` every 3 seconds and
// scraped column-aligned text for just SSID + RSSI. Now a single `net-status`
// call returns JSON with the SSID, signal in dBm, band, link bitrates and byte
// counters, and the interface is discovered instead of hardcoded to wlan0.
//
// Quickshell's native Quickshell.Networking module is deliberately NOT used: its
// NetworkBackendType only supports None and NetworkManager, and this machine runs
// iwd + networkd, so it would report no backend at all.
Item {
    id: root

    // ---- existing API, unchanged for consumers ------------------------------
    property string connectedSsid: "No Internet"
    property int signalStrength: 0 // 0-100 %
    property bool wifiEnabled: true

    readonly property bool connected: connectedSsid !== "No Internet" && connectedSsid.length > 0

    // ---- added ---------------------------------------------------------------
    property string device: ""      // interface carrying traffic (may be tailscale0)
    property string wifiDevice: ""  // the wireless interface itself
    property string kind: "none"    // wifi | other | none
    property var signalDbm: null
    property string band: ""        // "2.4" | "5" | "6"
    property var freqMhz: null
    property var rxBitrate: null    // Mbit/s, link rate
    property var txBitrate: null

    // Throughput, bytes/sec, derived from counter deltas.
    property real rxRate: 0
    property real txRate: 0

    property var pingMs: null           // most recent sample
    property real pingAvgMs: 0
    property int packetLossPercent: 0

    // Rolling window of ping results; null entries are lost packets, which is how
    // loss is derived. Kept short so the average tracks recent conditions.
    property var pingSamples: []
    readonly property int pingWindow: 10

    property double _prevRxBytes: -1
    property double _prevTxBytes: -1
    property double _prevSampleMs: 0

    function formatRate(bytesPerSec) {
        if (!isFinite(bytesPerSec) || bytesPerSec < 0)
            return "0 B/s";
        if (bytesPerSec < 1024)
            return Math.round(bytesPerSec) + " B/s";
        if (bytesPerSec < 1024 * 1024)
            return (bytesPerSec / 1024).toFixed(1) + " KiB/s";
        return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MiB/s";
    }

    function bandLabel() {
        return root.band === "" ? "" : root.band + " GHz";
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            statusProc.running = false;
            statusProc.running = true;
        }
    }

    // Separate and slower: a lost packet costs a full second (ping -W 1), which
    // must not delay the status refresh above.
    Timer {
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            pingProc.running = false;
            pingProc.running = true;
        }
    }

    Process {
        id: statusProc
        // Absolute path: ~/bin is only on the service PATH because uwsm imported
        // the session environment, which is not guaranteed at every start.
        command: [Quickshell.env("HOME") + "/bin/net-status"]

        stdout: StdioCollector {
            onStreamFinished: {
                let s;
                try {
                    s = JSON.parse(text);
                } catch (e) {
                    return; // partial read: keep the previous values
                }

                root.device = s.dev || "";
                root.wifiDevice = s.wifiDev || "";
                root.kind = s.kind || "none";
                root.wifiEnabled = s.powered === true;

                root.connectedSsid = (s.ssid && s.ssid.length > 0) ? s.ssid : "No Internet";
                root.signalStrength = s.quality || 0;
                root.signalDbm = s.signalDbm;
                root.freqMhz = s.freqMhz;
                root.band = s.band || "";
                root.rxBitrate = s.rxBitrate;
                root.txBitrate = s.txBitrate;

                // Counter deltas over real elapsed time, so the rate stays correct
                // even if a tick is late.
                const now = Date.now();
                if (root._prevRxBytes >= 0 && root._prevSampleMs > 0) {
                    const secs = (now - root._prevSampleMs) / 1000;
                    if (secs > 0) {
                        // Counters reset when the interface goes down; a negative
                        // delta means that happened, so report 0 rather than a
                        // huge negative spike.
                        const dRx = s.rxBytes - root._prevRxBytes;
                        const dTx = s.txBytes - root._prevTxBytes;
                        root.rxRate = dRx >= 0 ? dRx / secs : 0;
                        root.txRate = dTx >= 0 ? dTx / secs : 0;
                    }
                }
                root._prevRxBytes = s.rxBytes;
                root._prevTxBytes = s.txBytes;
                root._prevSampleMs = now;
            }
        }
    }

    Process {
        id: pingProc
        command: [Quickshell.env("HOME") + "/bin/net-ping"]

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim();
                const value = raw.length > 0 ? parseFloat(raw) : NaN;
                const sample = isFinite(value) ? value : null;

                root.pingMs = sample;

                let samples = root.pingSamples.slice();
                samples.push(sample);
                while (samples.length > root.pingWindow)
                    samples.shift();
                root.pingSamples = samples;

                let sum = 0, ok = 0, lost = 0;
                for (var i = 0; i < samples.length; i++) {
                    if (samples[i] === null)
                        lost++;
                    else {
                        sum += samples[i];
                        ok++;
                    }
                }
                root.pingAvgMs = ok > 0 ? sum / ok : 0;
                root.packetLossPercent = samples.length > 0 ? Math.round((lost / samples.length) * 100) : 0;
            }
        }
    }

    // Kept for compatibility with the existing panel. Still iwctl, because turning
    // the radio on and off is iwd's business, not something iw or sysfs exposes.
    function toggleWifi() {
        const dev = root.wifiDevice !== "" ? root.wifiDevice : "wlan0";
        wifiToggleProc.command = ["iwctl", "device", dev, "set-property", "Powered", root.wifiEnabled ? "off" : "on"];
        wifiToggleProc.running = false;
        wifiToggleProc.running = true;

        // Optimistic, so the switch responds immediately; the next status tick
        // corrects it if the command failed.
        root.wifiEnabled = !root.wifiEnabled;
    }

    Process {
        id: wifiToggleProc
        command: []
    }

    IpcHandler {
        target: "network"

        function status(): string {
            return JSON.stringify({
                ssid: root.connectedSsid,
                quality: root.signalStrength,
                signalDbm: root.signalDbm,
                band: root.band,
                rxBitrate: root.rxBitrate,
                txBitrate: root.txBitrate,
                rxRate: root.formatRate(root.rxRate),
                txRate: root.formatRate(root.txRate),
                pingMs: root.pingMs,
                pingAvgMs: Math.round(root.pingAvgMs * 10) / 10,
                packetLossPercent: root.packetLossPercent,
                device: root.device,
                wifiDevice: root.wifiDevice,
                kind: root.kind,
                powered: root.wifiEnabled
            });
        }
    }
}
