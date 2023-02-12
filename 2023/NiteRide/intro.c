/* NiteRide 
 * 2023-2-9
 * y0bi / wAMMA
 */

#define true 1
#define false 0

int main() {
  /* Point straight to ram  */
  unsigned char far * VGA=0xa0000000;
  unsigned char far * Virt=0x60000000;
  unsigned char far * Texture=0x80000000;

  int t=0,esc;

  asm mov ax,13h
  asm int 10h

  do {
    /* Routines are separated into blocks. The following one
       projects the trees onto a plane*/
    {
      unsigned int d,j;
      int p,i,x,y;
      
      p=50*320;
      for ( j=0 ; j <= 149 ; j++) { 
        for ( i=0 ; i <= 319 ; i++) {
          asm mov ax,40000
          asm mov bx,j
          asm inc bx
          asm xor dx,dx
          asm div bx
          asm mov d,ax

          x=(((((i-160)*d+t) >> 9))&127)-63;
          y=((d+34)&127)-63;
          Texture[p]=((x*y) &3 ) + ((x*x+y*y) < 6500 ? 0 : 15);
          p++;
        }
      }
    }

    /* Draw shadows on the plane in screen space */
    {  
      int c,i,j,y,p,x,y2;
      
      for ( j=-63 ; j <= 63 ; j++) { 
        y=j << 7;
        for ( i=0 ; i <= 319 ; i++) {
          y2=120+(y >>9);
          p=i+(y2)*320;
          c=Texture[p];
          if (y2 > 199) {
            break;
          }
          if ( c>8) {
            Virt[p]=c;
            break;
          }
            
          x = j < 0 ? -j : j;
          c+=31-(x >> 2);
          Virt[p]=c > 31 ? 31 : c;
          y+=j;
        }
      }
    }
    
    /*Draw trees on the plane starting from the bottom of the screen*/
    {
      unsigned int p;
      int found,i,j,c;
      
      for ( i=0 ; i <= 319 ; i++) { 
        p=i+320*198;
        found=false;
        for (j=0 ; j <= 198 ; j++) { 
          if (Texture[p] > 8 && !found) {
            c=Virt[p-1+2*320] | Virt[p-1+320];
            found=true;
          }
          if (found) {
            Virt[p]=c;
          }
          p-=320;
        }
      }
    }

    asm mov dx,3dah
Wait1:
    asm in al,dx
    asm and al,00001000b
    asm jz Wait1
Wait2:
    asm in al,dx
    asm and al,00001000b
    asm jnz Wait2

    /* Flippety floppety and clear some buffers */
    {
      unsigned int i;
      for (i=0;i<=65534;i++) {
        VGA[i]=Virt[i];
        Virt[i]=0;
      }
    }

    t+=1024;
    asm xor ax,ax
    asm in al,60h
    asm mov esc,ax
  } while (esc !=1);
  
  asm mov ax,3h
  asm int 10h
}
