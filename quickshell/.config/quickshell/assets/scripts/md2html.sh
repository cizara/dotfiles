#!/usr/bin/env bash
set -euo pipefail

# Read markdown from stdin
md="$(cat)"

# If cmark-gfm is missing, output a visible error (still valid rich text)
if ! command -v cmark-gfm >/dev/null 2>&1; then
  cat <<'HTML'
<font face="Adwaita Sans" size="2" color="#f38ba8">
<b>Markdown preview needs <tt>cmark-gfm</tt>.</b><br/>
Install (Arch): <tt>sudo pacman -S cmark-gfm</tt>
</font>
HTML
  exit 0
fi

# Convert Markdown -> HTML fragment (GFM-like)
html="$(printf "%s" "$md" | cmark-gfm --unsafe --extensions table,strikethrough,tasklist,autolink)"

# Convert to Qt RichText friendly HTML:
# - strong/em/del -> b/i/s
# - code -> tt (monospace)
# - task list inputs -> unicode checkboxes
# - headings -> font sizes + bold (Qt reliably supports <font>, <b>, <p>)
# - wrap everything in <font> for consistent theme
printf "%s" "$html" | perl -0777 -pe '
  s/<strong>/<b>/g; s/<\/strong>/<\/b>/g;
  s/<em>/<i>/g;     s/<\/em>/<\/i>/g;
  s/<del>/<s>/g;    s/<\/del>/<\/s>/g;

  s/<code[^>]*>/<tt>/g; s/<\/code>/<\/tt>/g;

  # task list checkboxes (checked first)
  s/<input[^>]*type="checkbox"[^>]*checked[^>]*>/☑ /gsi;
  s/<input[^>]*type="checkbox"[^>]*>/☐ /gsi;

  # strip leftover attributes that sometimes confuse Qt
  s/\sclass="[^"]*"//g;
  s/\sstyle="[^"]*"//g;

  # headings into font sizes
  s/<h1>(.*?)<\/h1>/<p><font size="5" color="#f1f5ff"><b>$1<\/b><\/font><\/p>/gsi;
  s/<h2>(.*?)<\/h2>/<p><font size="4" color="#f1f5ff"><b>$1<\/b><\/font><\/p>/gsi;
  s/<h3>(.*?)<\/h3>/<p><font size="3" color="#f1f5ff"><b>$1<\/b><\/font><\/p>/gsi;
  s/<h4>(.*?)<\/h4>/<p><font size="3" color="#f1f5ff"><b>$1<\/b><\/font><\/p>/gsi;
  s/<h5>(.*?)<\/h5>/<p><font size="2" color="#f1f5ff"><b>$1<\/b><\/font><\/p>/gsi;
  s/<h6>(.*?)<\/h6>/<p><font size="2" color="#f1f5ff"><b>$1<\/b><\/font><\/p>/gsi;

  # make links readable
  s/<a /<a style="color:#b4befe; text-decoration:none;" /g;

  $_ = qq(<font face="Adwaita Sans" size="2" color="#cdd6f4">) . $_ . qq(</font>);
'
