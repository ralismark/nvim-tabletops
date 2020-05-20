let tabletops#loaded = 1

function! tabletops#start()
	lua require("tabletops").start()

	augroup tabletops
		au!
		au VimLeavePre * call tabletops#stop()
	augroup END
endfunction

function! tabletops#stop()
	lua require("tabletops").stop()
endfunction

function! tabletops#on_receive(json)
	let data = json_decode(a:json)
	if data.messageID == 0
		call s:on_push(data)
	elseif data.messageID == 1
		call s:on_load(data)
	elseif data.messageID == 2
		call s:on_print(data)
	elseif data.messageID == 3
		call s:on_error(data)
	elseif data.messageID == 4
		call s:on_custom(data)
	elseif data.messageID == 5
		call s:on_return(data)
	elseif data.messageID == 6
		call s:on_save(data)
	elseif data.messageID == 7
		call s:on_create(data)
	else
		" Unknown message id
		echoerr "tabletops: Received unknown message id " data.messageID
	endif
endfunction

function! s:on_push(data)
	for state in a:data.scriptStates
		echomsg "tabletops: push got" state.name
		call s:load_object(state, 0)
	endfor
endfunction

function! s:on_load(data)
	" for state in a:data.scriptStates
	" 	echomsg "tabletops: load got" state.name
	" endfor
endfunction

function! s:on_print(data)
	echo a:data.message
endfunction

function! s:on_error(data)
	echoerr a:data.errorMessagePrefix "\n" a:data.error
endfunction

function! s:on_custom(data)
endfunction

function! s:on_return(data)
endfunction

function! s:on_save(data)
endfunction

function! s:on_create(data)
endfunction

function! s:send(data)
	let json = json_encode(a:data)
	call luaeval("require('tabletops').send(_A)", json)
endfunction

function! s:save_object()
	let contents = join(getbufline("%", 1, "$"), "\r\n")
	let b:tabletops_original.script = contents
	let message = {
	\ "messageID": 1,
	\ "scriptStates": [ b:tabletops_original ]
	\ }
	call s:send(message)
	set nomodified
endfunction

function! s:load_object(object, hide)
	let script = split(a:object.script, "\r\n")
	let name = "tts://" . a:object.guid . ":" . a:object.name

	let existing = bufnr(name)
	if existing != -1
		exec "sbuffer" existing
		%delete _
	else
		new
		exec "file" l:name
	endif

	setl buftype=acwrite filetype=lua
	augroup tabletops_buffer
		au!
		au BufWriteCmd,FileWriteCmd,FileAppendCmd <buffer> call s:save_object()
	augroup END
	let b:tabletops_original = a:object
	call append('$', script)
	0delete _
	set nomodified
	if a:hide
		hide
	endif

	" TODO load UI XMLS
	" let ui_xml = get(a:object, "ui")
endfunction
