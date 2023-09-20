    device zxspectrum48

    org 24576
    incbin "motr/motr.bin"

CHEAT_TIMEOUT equ 50 ; about 3s
CHEAT_PENALTY equ 10 ; lives taken for using invuln
PROC_TYPE_NUMBER equ 0xb7e4
PROC_TYPE_TEXT   equ 0xb86f

    org 0x9343
    ; a starter kit to complete the game
    db 0xff ; 01 compass  
    db 0    ; 02 jetpack   - obvs flying scenes
    db 0xff ; 03 disguise 
    db 0    ; 04 rope      - allows accessing top of the tree stump
    db 0xff ; 05 generator
    db 0xff ; 06 lasergun 
    db 0xff ; 07 watch    
    db 0xff ; 08 ladder   
    db 0xff ; 09 grenade  
    db 0xff ; 10 gun      
    db 0xff ; 11 floppy   
    db 0    ; 12 passport - required for a happy ending. I like the passportless one better, though
    db 0    ; 13 gasmask  - opens door that allows passing into the sewage works after picking up the cake
    db 0xff ; 14 telescope
    db 0xff ; 15 tank     
    db 0    ; 16 rum      - required when collecting the key on the ship for the exit to open
    db 0xff ; 17 axe      
    db 0xff ; 18 kit_bag  
    db 0xff ; 19 map      
    db 0xff ; 20 hammer   
    db 0xff ; 21 torch    

    org 0xabd2
    db 2 ; selected menu item

    org 0x98b2
    ; do not print lives; we use it for invuln indication
    ret

    org 0xae3e
    ; hook into the keyboard routine
    call Cht ; orig: ld bc, 0xeffe


    org 0x879b
    ; conventional death
    ; dec (hl); jr nz, 0x87ad
    jp Death
DEATH_RET_CONVENTIONAL equ 0x87ad

    org 0x9d2d
    ; death by sinclair's car
    ; dec (hl); jp nz, 0x98af
    jp Death_by_car
DEATH_RET_CAR equ 0x98af


    org 0xb866
    ; ld hl, (maybe_hiscore_print)
    ld hl, (death_counter)


    org 0xb887
    ;  " HISCORE:"
    db "  DEATHS:"


    org 0xaa61
    ; kill the menu music player for good
    halt
    halt
    halt
    halt
    halt
    ret


    org 0xf938
    ; here was music
Cht ld a, (cht_enabled)
    or a
    jr nz, cht_countdown

    ld bc, 0xfbfe
    in a, (c)
    bit 3, a ; FBFE:3 = R key
    jr nz, cht_quit

cht_enable
    ld a, CHEAT_TIMEOUT
    ld (cht_enabled), a

    call cht_indicate
    
    ; enable invuln
    ld hl, 36765
    ld a, (hl)
    ld (smc1 + 1), a
    ld a, 201
    ld (hl), a

    ld hl, 34445
    ld a, (hl)
    ld (smc2 + 1), a
    ld a, 201
    ld (hl), a

    ld hl, 39504
    ld a, (hl)
    ld (smc3 + 1), a
    ld a, 0
    ld (hl), a

    ld hl, (death_counter)
    ld de, CHEAT_PENALTY
    add hl, de
    ld (death_counter), hl
    ; update death counter on screen
    ld bc, 0x001b
    call PROC_TYPE_NUMBER

cht_quit
    ld bc, 0xeffe ; original code
    ret

cht_countdown
    dec a
    ld (cht_enabled), a
    jr nz, cht_quit

    call cht_indicate

    ; disable invuln
smc1 ld a, 0
    ld (36765), a
smc2 ld a, 0
    ld (34445), a
smc3 ld a, 0
    ld (39504), a

    jr cht_quit

cht_indicate:
    push ix
    ld ix, txt_cht_on
    or a
    jr nz, 1f
    ld ix, txt_cht_off
1   ld bc, 0x000e
    call PROC_TYPE_TEXT
    pop ix
    ret

txt_cht_on db "INV", 0ffh
txt_cht_off db "   ", 0ffh


cht_enabled db 0
death_counter dw 0

Death_by_car:
    ld hl, DEATH_RET_CAR
    jr 1f

Death:
    ld hl, DEATH_RET_CONVENTIONAL
1   push hl ; will ret here
    ld hl, (death_counter)
    inc hl
    ld (death_counter), hl

    ; update death counter on screen
    ld bc, 0x001b
    jp PROC_TYPE_NUMBER


    savebin "out/motr.patched.bin", 0x6000, 40960
