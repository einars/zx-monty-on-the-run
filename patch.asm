    device zxspectrum48

    org 24576
    incbin "motr/motr.bin"

    org 0xae3e
    ; te tiek lasīta klaviatūra
    call cht ; orig: ld bc, 0xeffe


    org 0x879b
infinite_lives:
    or (hl) ; dec (hl)

    org 0xaa61
play_music:
    halt
    halt
    halt
    halt
    halt
    ret

    org 0xf938
    ; here was music
cht:
    ld a, (cht_enabled)
    or a
    jr nz, cht_countdown

    ld bc, 0xfbfe
    in a, (c)
    bit 3, a ; FBFE:3 = R key
    jr nz, cht_quit

cht_enable
    ld a, 50
    ld (cht_enabled), a
    ld a, 0x03
    out (0xfe), a ; border indication
    
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

cht_quit
    ld bc, 0xeffe ; original code
    ret

cht_countdown
    dec a
    ld (cht_enabled), a
    jr nz, cht_quit

cht_disable
    ; disable invuln
smc1 ld a, 0
    ld (36765), a
smc2 ld a, 0
    ld (34445), a
smc3 ld a, 0
    ld (39504), a

    ; border indication
    xor a
    out (0xfe), a
    jr cht_quit

cht_enabled db 0

    savebin "out/motr.patched.bin", 0x6000, 40960
