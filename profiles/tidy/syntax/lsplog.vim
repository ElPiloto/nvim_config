" Syntax file to make it easier to view the output of :LspLog
setlocal iskeyword+=.
setlocal iskeyword+=$
setlocal iskeyword+=\/
setlocal iskeyword+=\"
set synmaxcol=0

syntax match lspLogRPCSend "\ .*rpc\.send\".*$"
syntax match lspLogRPCReceive "\ .*rpc\.receive\".*$"
syntax match lspLogLSP "\ .*LSP\[.*\]\".*$"
syntax match lsplogLevel "\[[A-Z]*\]\[[0-9:\-\ ]*\]"


syntax match lsplogLSPMethod "method\ =\ \"[\$\/]*[a-zA-Z0-9]*\/[a-zA-Z0-9]*\"" contained containedIn=lsplogRPCSend,lsplogRPCReceive

syntax match lsplogLSPInitialize "method\ =\ \"initialize\"" contained containedIn=lsplogRPCSend
syntax keyword lsplogLSPServerCapabilities \"server_capabilities\" \"initialized\"

highlight link lsplogRPCSend Tag
highlight link lsplogRPCReceive Character
highlight link lsplogLSP Include
highlight link lsplogLSPMethod DiagnosticInfo
highlight link lsplogLSPInitialize Underlined
highlight link lsplogLSPServerCapabilities Underlined
highlight link lsplogLevel WildMenu
