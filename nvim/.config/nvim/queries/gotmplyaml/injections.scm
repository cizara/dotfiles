; Inject gotmpl into the entire yaml document (no ; extends — avoids yaml injection queries on ERROR nodes)
((stream) @injection.content
  (#set! injection.language "gotmpl")
  (#set! injection.combined))
