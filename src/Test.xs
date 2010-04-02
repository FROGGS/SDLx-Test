#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef aTHX_
#define aTHX_
#endif

#include <SDL.h>

MODULE = SDLx::Test 	PACKAGE = SDLx::Test    PREFIX = test_

=for documentation

returning percentage how many pixels are equal
returning percentage of average color consistence for red, green, blue and alpha

=cut

AV *
test_compare_surfaces( surface1, surface2 )
	SDL_Surface *surface1
	SDL_Surface *surface2
	CODE:
		if(surface1->w != surface2->w || surface1->h != surface2->h)
			XSRETURN_UNDEF;
		else
		{
			Uint8 r1, g1, b1, a1, r2, g2, b2, a2;
			int pixel_count    = surface1->w * surface1->h;
			int wrong_pixels   = 0;
			double good_pixels = 0;
			double cmp_r       = 0;
			double cmp_g       = 0;
			double cmp_b       = 0;
			double cmp_a       = 0;
			Uint32 pixel;
			
			SDL_LockSurface(surface1);
			SDL_LockSurface(surface2);
			int index = 0;
			for(index = 0; index < pixel_count; index++)
			{
				switch(surface1->format->BytesPerPixel)
				{
					case 1: SDL_GetRGBA(((Uint8  *)surface1->pixels)[index], surface1->format, &r1, &g1, &b1, &a1); break;
					case 2: SDL_GetRGBA(((Uint16 *)surface1->pixels)[index], surface1->format, &r1, &g1, &b1, &a1); break;
					case 3:
						pixel = ((Uint32)((Uint8 *)surface1->pixels)[index * surface1->format->BytesPerPixel]     <<  0)
						      + ((Uint32)((Uint8 *)surface1->pixels)[index * surface1->format->BytesPerPixel + 1] <<  8)
						      + ((Uint32)((Uint8 *)surface1->pixels)[index * surface1->format->BytesPerPixel + 2] << 16);
						SDL_GetRGBA(pixel, surface1->format, &r1, &g1, &b1, &a1);
						break;
					case 4: SDL_GetRGBA(((Uint32 *)surface1->pixels)[index], surface1->format, &r1, &g1, &b1, &a1); break;
				}
				
				switch(surface2->format->BytesPerPixel)
				{
					case 1: SDL_GetRGBA(((Uint8  *)surface2->pixels)[index], surface2->format, &r2, &g2, &b2, &a2); break;
					case 2: SDL_GetRGBA(((Uint16 *)surface2->pixels)[index], surface2->format, &r2, &g2, &b2, &a2); break;
					case 3:
						pixel = ((Uint32)((Uint8 *)surface2->pixels)[index * surface2->format->BytesPerPixel]     <<  0)
						      + ((Uint32)((Uint8 *)surface2->pixels)[index * surface2->format->BytesPerPixel + 1] <<  8)
						      + ((Uint32)((Uint8 *)surface2->pixels)[index * surface2->format->BytesPerPixel + 2] << 16);
						SDL_GetRGBA(pixel, surface2->format, &r2, &g2, &b2, &a2);
						break;
					case 4: SDL_GetRGBA(((Uint32 *)surface2->pixels)[index], surface2->format, &r2, &g2, &b2, &a2); break;
				}
				
				if(r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2)
					good_pixels++;
				
				if(0 == r1) r1 = 1;
				if(0 == r2) r2 = 1;
				cmp_r += ((double)r1 < (double)r2) ? (double)r1 / (double)r2 : (double)r2 / (double)r1;
				
				if(0 == g1) g1 = 1;
				if(0 == g2) g2 = 1;
				cmp_g += ((double)g1 < (double)g2) ? (double)g1 / (double)g2 : (double)g2 / (double)g1;
				
				if(0 == b1) b1 = 1;
				if(0 == b2) b2 = 1;
				cmp_b += ((double)b1 < (double)b2) ? (double)b1 / (double)b2 : (double)b2 / (double)b1;
				
				if(0 == a1) a1 = 1;
				if(0 == a2) a2 = 1;
				cmp_a += ((double)a1 < (double)a2) ? (double)a1 / (double)a2 : (double)a2 / (double)a1;
			}
			SDL_UnlockSurface(surface1);
			SDL_UnlockSurface(surface2);
			
			good_pixels /= (double)pixel_count / 100;
			cmp_r       /= (double)pixel_count / 100;
			cmp_g       /= (double)pixel_count / 100;
			cmp_b       /= (double)pixel_count / 100;
			cmp_a       /= (double)pixel_count / 100;
			
			RETVAL = newAV();
			sv_2mortal((SV*)RETVAL);
			av_push(RETVAL, newSVnv(good_pixels));
			av_push(RETVAL, newSVnv(cmp_r));
			av_push(RETVAL, newSVnv(cmp_g));
			av_push(RETVAL, newSVnv(cmp_b));
			av_push(RETVAL, newSVnv(cmp_a));
		}
	OUTPUT:
		RETVAL
