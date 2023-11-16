format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable ; .data можно изменить(до 8 символов)
      array dd 6 dup(0)
      current_number dd 0
      format_number db '%d', 0
      rows dd 2
      columns dd 3
      array_size dd 0
      get_number db 'Input number: ', 0
      n dd 0
      num1 dd 0
      num2 dd 0
      num3 dd 0
      num4 dd 0
      not_in_array dd 1000000
      format_number_output db '%d', 10, 13

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
                mov eax, [rows]
                imul eax, [columns]
                mov [array_size], eax

                mov esi, 0
                get_numbers:
                        push get_number
                        call [printf]

                        push current_number
                        push format_number
                        call [scanf]

                        mov eax, [current_number]
                        mov [array + 4*esi], eax
                        add esi, 1
                        add [n], 1

                fld [n]
                fld [array_size]
                fcomip st0, st1
                jne get_numbers

                mov esi, 0
                decide_first:
                       mov eax, esi ; проверка это самый правый элемент или нет (если esi + 1 / columns не имеет остатка, то самый правый)
                       add eax, 1
                       mov ecx, [columns]
                       mov edx, 0
                       cdq
                       idiv ecx
                       cmp edx, 0
                       je first_is_none
                       mov ebx, [array + 4*esi + 4] ; след элемент
                       mov [num1], ebx
                       jmp decide_second
                       first_is_none:
                               mov eax, [not_in_array]
                               mov [num1], eax
                decide_second:
                       mov eax, esi ; проверка это самый левый элемент или нет (если esi + 1 / columns имеет остаток 1, то самый левый)
                       add eax, 1
                       mov ecx, [columns]
                       mov edx, 0
                       cdq
                       idiv ecx
                       cmp edx, 1
                       je second_is_none
                       mov ebx, [array + 4*esi - 4] ; пред элемент
                       mov [num2], ebx
                       jmp decide_third
                       second_is_none:
                               mov eax, [not_in_array]
                               mov [num2], eax
                decide_third:
                       mov eax, esi ; проверка это сама€ верхн€€ строка или нет (если esi / columns имеет в результате 0, то сама€ верхн€€)
                       mov ecx, [columns]
                       mov edx, 0
                       cdq
                       idiv ecx
                       cmp eax, 0
                       je third_is_none
                       mov ebx, [array + 4*esi - 4*3] ; верхний элемент
                       mov [num3], ebx
                       jmp decide_fourth
                       third_is_none:
                               mov eax, [not_in_array]
                               mov [num3], eax
                decide_fourth:
                       mov eax, esi ; проверка это сама€ нижн€€ строка или нет (если esi / columns имеет в результате rows - 1, то сама€ нижн€€)
                       mov ecx, [columns]
                       mov edx, 0
                       cdq
                       idiv ecx
                       mov ebx, [rows]
                       sub ebx, 1
                       cmp eax, ebx
                       je fourth_is_none
                       mov ebx, [array + 4*esi + 4*3] ; нижний элемент
                       mov [num4], ebx
                       jmp compare_around_high
                       fourth_is_none:
                               mov eax, [not_in_array]
                               mov [num4], eax

                compare_around_high:
                        check_first_high:
                                mov eax,[not_in_array]
                                cmp eax, [num1]
                                je check_second_high
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num1]
                                jle compare_around_low
                        check_second_high:
                                mov eax,[not_in_array]
                                cmp eax, [num2]
                                je check_third_high
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num2]
                                jle compare_around_low
                        check_third_high:
                                mov eax,[not_in_array]
                                cmp eax, [num3]
                                je check_fourth_high
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num3]
                                jle compare_around_low
                         check_fourth_high:
                                mov eax,[not_in_array]
                                cmp eax, [num4]
                                je replace_high
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num4]
                                jle compare_around_low
                         replace_high:
                                mov [array + 4*esi], 0

                compare_around_low:
                        check_first_low:
                                mov eax,[not_in_array]
                                cmp eax, [num1]
                                je check_second_low
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num1]
                                jge check_end
                        check_second_low:
                                mov eax,[not_in_array]
                                cmp eax, [num2]
                                je check_third_low
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num2]
                                jge check_end
                        check_third_low:
                                mov eax,[not_in_array]
                                cmp eax, [num3]
                                je check_fourth_low
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num3]
                                jge check_end
                         check_fourth_low:
                                mov eax,[not_in_array]
                                cmp eax, [num4]
                                je replace_low
                                mov ebx, [array + 4*esi]
                                cmp ebx, [num4]
                                jge check_end
                         replace_low:
                                mov [array + 4*esi], 0
                check_end:
                        add esi, 1
                        cmp esi, [array_size]
                        jne decide_first
                mov esi, 0
                output:
                        mov eax, [array + 4*esi]
                        mov [current_number], eax
                        push [current_number]
                        push format_number_output
                        call [printf]
                        add esi, 1
                        cmp esi, [array_size]
                        jne output

                finish:
                        call [getch] ; ожидание конца всех операций
                        push 0
                        call [ExitProcess]
