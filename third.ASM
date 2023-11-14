format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable ; .data можно изменить(до 8 символов)
      array dd 0
      current_number dd 0
      format_number db '%d', 0
      rows dd 0
      columns dd 0
      array_size dd 0

section '.imports' import data readable
        library kernel, 'kernel32.dll', \
                msvcrt, 'msvcrt.dll'
        import kernel, \
               ExitProcess, 'ExitProcess'
        import msvcrt, \
               printf, 'printf', \
               scanf, 'scanf', \
               getch, '_getch', \
               malloc,'malloc',\
               free,'free'

section '.code' code readable executable
        start:
                push rows
                push format_number
                call [scanf]

                push columns
                push format_number
                call [scanf]

                mov eax, [rows]
                imul eax, [columns]
                mov [array_size], eax

                ;push [array_size]
                ;push format_number
                ;call [printf]

                mov eax, 0
                mov esi, array
                mov eax, [rows]
                ;mov [array], eax
                mov [array + 4], eax
                add esi, 4    ; +4 -> следующий элемент массива
                add eax, [esi]
                mov [current_number], eax
                push [current_number]
                push format_number
                call [printf]

                finish:
                        call [getch] ; ожидание конца всех операций
                        push 0
                        call [ExitProcess]
