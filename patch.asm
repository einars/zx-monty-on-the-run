    device zxspectrum48

    org 24576
    incbin "motr/motr.bin"

    org 34716
infinite_lives:
    or (hl)

    org 0xaa61
play_music:
    ret

    savebin "out/motr.patched.bin", 0x6000, 40960
