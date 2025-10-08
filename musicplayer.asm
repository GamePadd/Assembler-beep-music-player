format PE console
entry start

include "win32ax.inc"

section ".data" data writable readable
	file_name 				db 256 dup(0)
	file_dir				db "music/", 0
	open_mode 				db "r", 0
	
	format_char 			db "%c", 0
	format_str				db "%s", 0
	format_str_double		db "%s%s", 10, 0
	format_str_triple		db "%s%s%s", 10, 0
	format_str_triple_path	db "%s%s%s", 0
	format_scan 			db "%d %d", 0
	
	file_ext				db ".mpf", 0
	file_ptr				dd 0
	full_path				db 256 dup(0)

	;bytes_read				dd 0
	buffer					db 64 dup(0)
	
	error_str				db 10, "Error, file did not open!", 0
	end_str					db "End of file!", 10, 0
	br_str					db "Bytes read: %d", 0
	start_str				db "File name: ", 0
	fl_str					db "Full path: ", 0
	note_print				db "Frequency: %d, Duration: %d", 10, 0
	
	frequency				dd 0
	duration				dd 0
	cooldown				dd 50

section ".code" code readable executable
	start:
		push start_str
		push format_str
		call [printf]
		add esp, 8
		
		push file_name
		push format_str
		call [scanf]
		add esp, 8
		
		push file_ext
		push file_name
		push file_dir
		push format_str_triple_path
		push full_path
		call [sprintf]
		add esp, 20
		
		push full_path
		push fl_str
		push format_str_double
		call [printf]
		add esp, 12
		
		push open_mode
		push full_path
		call [fopen]
		add esp, 8
		
		mov [file_ptr], eax
		
		test eax, eax
		jz error
		
		;mov [bytes_read], 0
		
	read_lines:
		push [file_ptr]
		push 64
		push buffer
		call [fgets]
		add esp, 12
		
		test eax, eax
		jz en
		
		push duration
		push frequency
		push format_scan
		push buffer
		call [sscanf]
		add esp, 16
		
		push [duration]
		push [frequency]
		push note_print
		call [printf]
		add esp, 12
		
		push [duration]
		push [frequency]
		call [Beep]
		invoke Sleep, [cooldown]
		
		cmp eax, -1
		je en
		
		inc esi
		;inc [bytes_read]
		
		jmp read_lines
	error:
		push error_str
		call [printf]
		call [getch]
		add esp, 4
		invoke ExitProcess, 1
	en:
		push [file_ptr]
		call [fclose]
		add esp, 4
		
		push end_str
		call [printf]
		add esp, 4
		
		;push [bytes_read]
		;push br_str
		;call [printf]
		call [getch]
		;add esp, 4
		invoke ExitProcess, 1
section ".idata" import data readable
	library kernel, "kernel32.dll",\
		user, "user32.dll",\
		msvcrt, "msvcrt.dll"
	
	import msvcrt,\
		printf, "printf",\
		scanf, "scanf",\
		getch, "_getch",\
		fopen, "fopen",\
		fclose, "fclose",\
		fgetc, "fgetc",\
		strcpy, "strcpy",\
		strcat, "strcat",\
		sprintf, "sprintf",\
		fgets, "fgets",\
		sscanf, "sscanf"
		
	import kernel,\
		ExitProcess, "ExitProcess",\
		Beep, "Beep",\
		Sleep, "Sleep"