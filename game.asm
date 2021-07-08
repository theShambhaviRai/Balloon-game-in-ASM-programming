.model large
.data

exit db 0
player_pos dw 1760d                       

arrow_pos dw 0d                           
arrow_status db 0d                          
arrow_limit dw  22d  

loon_pos dw 3860d       
loon_status db 0d
         
                                            
direction db 0d

state_buf db '00:0:0:0:0:0:00:00$'          
hit_num db 0d
hits dw 0d
miss dw 0d  

game_over_str dw '  ',0ah,0dh
dw '                             |               |',0ah,0dh
dw '                             |---------------|',0ah,0dh
dw '                             | ^   Score   ^ |',0ah,0dh
dw '                             |_______________|',0ah,0dh
dw ' ',0ah,0dh 
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw '                                Game Over',0ah,0dh
dw '                        Press Enter to start again$',0ah,0dh 


game_start_str dw '  ',0ah,0dh

dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw '                ====================================================',0ah,0dh
dw '               ||                                                  ||',0ah,0dh                                        
dw '               ||       *    Balloon Shooting Game      *          ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||--------------------------------------------------||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh          
dw '               ||     Use up and down key to move player           ||',0ah,0dh
dw '               ||          and space button to shoot               ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||            Press Enter to start                  ||',0ah,0dh 
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '                ====================================================',0ah,0dh
dw '$',0ah,0dh




.code
main proc
mov ax,@data
mov ds,ax

mov ax, 0B800h
mov es,ax 



jmp game_menu                              

                                                                   
main_loop:                                 
                                           
    mov ah,1h
    int 16h                                
    jnz key_pressed
    jmp inside_loop                        
    
    inside_loop:                          
        
        cmp miss,9                         
        jge game_over
        
        mov dx,arrow_pos                   
        cmp dx, loon_pos
        je hit
        
        cmp direction,8d                  
        je player_up
        cmp direction,2d                   
        je player_down
        
        mov dx,arrow_limit                 
        cmp arrow_pos, dx
        jge hide_arrow
        
        cmp loon_pos, 0d                   
        jle miss_loon
        jne render_loon 
    
        hit:                             
            mov ah,2
            mov dx, 7d
            int 21h 
            
            inc hits                       
            
            lea bx,state_buf               
            call show_score 
            lea dx,state_buf
            mov ah,09h
            int 21h
            
            mov ah,2                      
            mov dl, 0dh
            int 21h    
            
            jmp fire_loon                  
    
        render_loon:                       
            mov cl, ' '                    
            mov ch, 1111b
        
            mov bx,loon_pos 
            mov es:[bx], cx
                
            sub loon_pos,160d              
            mov cl, 15d
            mov ch, 1101b
        
            mov bx,loon_pos 
            mov es:[bx], cx
            
            cmp arrow_status,1d            
            je render_arrow
            jne inside_loop2 
        
        render_arrow:                      
        
            mov cl, ' '
            mov ch, 1111b
        
            mov bx,arrow_pos               
            mov es:[bx], cx
                
            add arrow_pos,4d              
            mov cl, 26d
            mov ch, 1001b
        
            mov bx,arrow_pos 
            mov es:[bx], cx
        
        inside_loop2:
            
            mov cl, 125d                  
            mov ch, 1100b
            
            mov bx,player_pos 
            mov es:[bx], cx
            
             
                       
    cmp exit,0
    je main_loop                          
    jmp exit_game
 
jmp inside_loop2
    
player_up:                                
    mov cl, ' '
    mov ch, 1111b
        
    mov bx,player_pos 
    mov es:[bx], cx
    
    sub player_pos, 160d                  
    mov direction, 0    

    jmp inside_loop2                     
    
player_down:
    mov cl, ' '                           
    mov ch, 1111b                        
                                          
    mov bx,player_pos 
    mov es:[bx], cx
    
    add player_pos,160d                  
    mov direction, 0
    
    jmp inside_loop2

key_pressed:                              
    mov ah,0
    int 16h

    cmp ah,48h                            
    je upKey
    cmp ah, 50h
    je downKey
    
    cmp ah,39h                           
    je spaceKey
    
    cmp ah,4Bh                            
    je leftKey
     
                                          
    jmp inside_loop

leftKey:                                
  
    inc miss
            
    lea bx,state_buf
    call show_score 
    lea dx,state_buf
    mov ah,09h
    int 21h
    
    mov ah,2
    mov dl, 0dh
    int 21h
jmp inside_loop
    
upKey:                                    
    mov direction, 8d
    jmp inside_loop

downKey:
    mov direction, 2d                    
    jmp inside_loop
    
spaceKey:                               
    cmp arrow_status,0
    je  fire_arrow
    jmp inside_loop

fire_arrow:                               
    mov dx, player_pos                    
    mov arrow_pos, dx
    
    mov dx,player_pos                     
    mov arrow_limit, dx                  
    add arrow_limit, 22d  
    
    mov arrow_status, 1d                 
    jmp inside_loop                    

miss_loon:
    add miss,1                           

    lea bx,state_buf                      
    call show_score 
    lea dx,state_buf
    mov ah,09h
    int 21h
                                          
    mov ah,2
    mov dl, 0dh
    int 21h
jmp fire_loon
    
fire_loon:                                
    mov loon_status, 1d
    mov loon_pos, 3860d     
    jmp render_loon
    
hide_arrow:
    mov arrow_status, 0                  
    
    mov cl, ' '
    mov ch, 1111b
    
    mov bx,arrow_pos 
    mov es:[bx], cx
    
    cmp loon_pos, 0d 
    jle miss_loon
    jne render_loon 
    
    jmp inside_loop2
                                         
game_over:
    mov ah,09h
    mov dx, offset game_over_str
    int 21h
    
    
    
    mov cl, ' '                           
    mov ch, 1111b 
    mov bx,arrow_pos                      
    
    mov cl, ' '                          
    mov ch, 1111b 
    mov bx,player_pos  
                        
    mov miss, 0d
    mov hits,0d
    
    mov player_pos, 1760d

    mov arrow_pos, 0d
    mov arrow_status, 0d 
    mov arrow_limit, 22d     

    mov loon_pos, 3860d      
    mov loon_status, 0d
         
    mov direction, 0d
                                           
    input:
        mov ah,1
        int 21h
        cmp al,13d
        jne input
        call clear_screen
        jmp main_loop
    

game_menu:
                                           
    mov ah,09h
    mov dh,0
    mov dx, offset game_start_str
    int 21h
                                          
    input2:
        mov ah,1
        int 21h
        cmp al,13d
        jne input2
        call clear_screen
        
        lea bx,state_buf                  
        call show_score 
        lea dx,state_buf
        mov ah,09h
        int 21h
    
        mov ah,2
        mov dl, 0dh
        int 21h
        
        jmp main_loop

exit_game:                                 
mov exit,10d

main endp

proc show_score
    lea bx,state_buf
    
    mov dx, hits
    add dx,48d 
    
    mov [bx], 9d
    mov [bx+1], 9d
    mov [bx+2], 9d
    mov [bx+3], 9d
    mov [bx+4], 'H'
    mov [bx+5], 'i'                                        
    mov [bx+6], 't'
    mov [bx+7], 's'
    mov [bx+8], ':'
    mov [bx+9], dx
    
    mov dx, miss
    add dx,48d
    mov [bx+10], ' '
    mov [bx+11], 'M'
    mov [bx+12], 'i'
    mov [bx+13], 's'
    mov [bx+14], 's'
    mov [bx+15], ':'
    mov [bx+16], dx
ret    
show_score endp 

clear_screen proc near
        mov ah,0
        mov al,3
        int 10h        
        ret
clear_screen endp

end main
