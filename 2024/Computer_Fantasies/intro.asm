; Computer Fantasies
; y0bi / wAMMA
; 2024-2-11
  org 100h
 
  cpu 386   ; just for the fs segment register, so lazy ;)

  mov al,13h 
  int 10h

  push 0a000h
  pop fs
;-----------------------------------------------------------------------
  xor si,si
mainloop:
  push 3000h      ; stack top
  pop ds

  mov bp,si
  shr bp,10   ; Choose effect
  and bp,3
  
  mov ch,[effectSizes+bp]
  xor ax,ax
  mov al,[effectOffsets+bp]
  xchg bp,ax
;-----------------------------------------------------------------------
interpretloop:
  xor bx,bx
  call get3bits
  mov bl,al
  dec ch
  call get3bits
  shl al,1
  mov cl,al
;  shl cl,1
  
  mov dx,ds
  mov es,dx
  
  sub dh,8h      ; some op consume one array. TOS in ds, NOS in es
  cmp bl,4
  jb noxydup
  jne noinc     ; inc if it was a literal
  dec ch
noinc:
  add dh,10h     ; others produce one array, TOS in es
noxydup:
  mov ds,dx
  
  mov bl,[ss:opoffsets+bx]
  add bx,ops

  mov di,32766
oploop:            ; go trough the entire array
  mov ax,[es:di]
  mov dx,di
  call bx
  mov [di],ax
    
  test ch,ch
  jnz noflip

  push bx  
  mov bx,di
  shr bx,2
  mov [di],si
  shr al,4
  adc bl,0
  add al,64
  mov ah,al
  mov [fs:di+bx+32*320],ax
  pop bx
   
 noflip:
  
  dec di
  dec di
  jnz oploop
    
  test ch,ch
  jnz interpretloop
;-----------------------------------------------------------------------

  inc si
  
  in al,60h
  cmp al,1
  jne mainloop

ops:
addop:
  add ax,[di]
  ret             ; program exit is here
subop:
  sub ax,[di]
  neg ax
  ret
mulop:
  imul word [di]
  ret
divop:
  xchg ax,[di]
  cwd
  idiv word [di]
  ret
yop:  
  rol dx,9
xop:
  xchg ax,dx
  xor ah,ah
  shr ax,1
  ret
litop:
  mov ax,2
  shl ax,cl
dupop:
  ret
  
  
get3bits:
  mov al,3
  mul ch
  mov cl,al
  shr ax,3
  xchg ax,di              ; bx contains index to three bits
  mov ax,[di+bp+effect0]  ; get two bytes to handle overlap
  shl di,3                ; get start bit of loaded byte
  sub cx,di               ; get shift count, ch is not changed!
  shr ax,cl
  and al,7
  ret

  opoffsets db addop-ops,subop-ops,mulop-ops,divop-ops,litop-ops,xop-ops,yop-ops,dupop-ops

  effectOffsets db 0, effect1-effect0, effect2-effect0, effect3-effect0
   
  effectSizes db 6,30,24,62
  effect0 db 128,108,21
  effect1 db 192,70,101,224,88,144,209,51,112,180,41,17
  effect2 db 200,0,66,15,46,90,15,46,246,4
  effect3 db 128,158,129,98,36,78,60,198,141,202,192,177,3,104,83,207,64,49,18,39,30,3,104,19

    

