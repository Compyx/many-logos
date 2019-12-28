#!/usr/bin/env python3

import pprint


class SpritesHandler(object):
    """
    Base class for the sprite converters

    Loads Koala image and makes sure bitpairs in the entire image use the
    same colors.

    :param filename: path to koala image
    """

    # table of colors to reindex to bitpairs
    bitpairs = [ 0, 0, 0, 0,    # 00-03
                 0 ,0, 0, 0,    # 04-07
                 0, 0, 0, 2,    # 08-0B
                 1, 0, 0, 3]    # 0C-OF


    def __init__(self, filename):
        self_filename = filename
        with open(filename, 'rb') as infile:
            data = infile.read()
            self._bitmap = data[2:8002]
            self._vidram = data[8002:9002]
            self._colram = data[9002:10002]
            self._new_bitmap = bytearray(8000)

    @staticmethod
    def _char_data_offset(column, row):
        """
        Calculate offset in bitmap of 'char' at (column, row)

        :param column: column index (0-39)
        :param row: row index (0-24)

        :return: offset in bitmap of 'char' data
        """
        return row * 0x140 + column * 0x08

    @staticmethod
    def _char_colors_offset(column, row):
        return column + row * 40

    def get_char_data(self, column, row):
        offset = self._char_data_offset(column, row)
        return self._bitmap[offset:offset+8]

    def _get_char_colors(self, column, row):
        offset = self._char_colors_offset(column, row)
        return [0,
                self._vidram[offset] >> 4,
                self._vidram[offset] & 0x0f,
                self._colram[offset] & 0x0f]


    def _reindex_char(self, data, colors):
        """
        Reindex colors in a single 'char'
        """
        result = bytearray(8)

        for row in range(8):
            for b in range(4):
                old_bitpair = (data[row] >> (b * 2)) & 0x03
                color = colors[old_bitpair]
                new_bitpair = self.bitpairs[color]
                result[row] = result[row] | (new_bitpair << (b * 2))

        return result

    def reindex_colors(self):
        for row in range(5):
            for col in range(40):
                data = self.get_char_data(col, row)
                colors = self._get_char_colors(col, row)
                #print("{},{}: {}".format(row, col, data))
                #print("colors:  {}".format(colors))
                result = self._reindex_char(data, colors)
                #print("result: {}".format(bytes(result)))

                offset = self._char_data_offset(col, row)
                self._new_bitmap[offset:offset + 8] = result

    def write_reindexed_koala(self):
        """
        Debug hook: write reindexed koala to filesystem as 'reindexed.kla'
        """
        with open("reindexed.kla", "wb") as outfile:
            outfile.write(bytearray([0x00, 0x60]))
            outfile.write(self._new_bitmap)
            outfile.write(bytearray([0xcb] * 1000))
            outfile.write(bytearray([0x0f] * 1000))
            outfile.write(bytearray([0]))

    def get_bitmap_byte(self, column, ypos):
        """
        Get byte from reindexed bitmap

        :param column: column index in chars (0-39)
        :param ypos: vertical index in pixels (0-199)

        :return: byte at (column,ypos)
        """
        char_row = (int)(ypos >> 3)
        offset = self._char_data_offset(column, char_row)
        return self._new_bitmap[offset + (ypos & 0x07)]

    def get_sprite(self, column, ypos):
        sprite = bytearray(64)

        for y in range(21):
            for b in range(3):
                sprite[y * 3 + b] = self.get_bitmap_byte(column + b, y + ypos)

        return sprite


class SpritesHorizontal(SpritesHandler):
    """
    Convert Koala data to horizontal logo in sprites

    Results in a logo of 8x2 sprites (hopefully)
    """

    def __init__(self, filename):
        super().__init__(filename)
        self.reindex_colors()
        self._sprites = bytearray(16 * 0x40)

    @staticmethod
    def _sprite_offset(column, row):
        return (column + row * 8) * 0x40



    def convert(self):
        # first row
        for spr_x in range(8):
            self._sprites[spr_x * 64:(spr_x + 1) * 64] = self.get_sprite(
                spr_x * 3, 0)

        #second row
        for spr_x in range(8):
            self._sprites[spr_x * 64 + 0x200:(spr_x + 1) * 64 + 0x200] = self.get_sprite(
                spr_x * 3, 21)

    def make_stretched(self):
        """Interleave 2 sprites high for $d017 stretching + $d018 toggling"""

        data = bytearray(16 * 64)


        rows = [(r * 3, (int(r / 2 ) * 3 + (r % 2) * 0x200)) for r in range(42)]
        pprint.pprint(rows)

        for s in range(8):
            print("sprite {}:".format(s))
            for row, elem in enumerate(rows):
                src, dest = elem
                if (src % 0x40 == 0x3f):
                    src += 1

                src = src + s * 0x40
                dest = dest +s * 0x40

                print("copying row {}: {:04x}-{:04x} to {:04x}-{:04x}".format(
                    row, src, src + 2, dest, dest + 2))
                data[dest:dest + 3] = self._sprites[src:src + 3]

        self._stretched = data

    def write_sprites(self):
        with open("sprites-horizontal.bin", "wb") as outfile:
            outfile.write(self._sprites)
        with open("sprites-stretched.bin", "wb") as outfile:
            outfile.write(self._stretched)


class SpritesVertical(SpritesHandler):
    """
    Convert Koala data to vertical logo in sprites

    Each 'char' in 'focus' being 2x2 sprites
    """

    def __init__(self, filename):
        super().__init__(filename)
        self.reindex_colors()
        # vertical logo takes 2*2 * 5 sprites == 20 sprites
        self._sprites = bytearray(20 * 64)

    def _to_sprites(self, column):
        """

        :param column: column index in bitmap
        """

        result = bytearray(0x100)   # 4 sprites

        result[0:64] = self.get_sprite(column, 0);
        result[64:128] = self.get_sprite(column + 3, 0)
        result[128:192] = self.get_sprite(column, 21)
        result[192:256] = self.get_sprite(column + 3, 21)

        return result


    def _wipe_sprite(self, sprite, cols):
        """
        Wipe columns of a sprite, starting at the right
        """

        if cols < 1:
            return
        for x in range(5, 5 - cols, -1):
            print("wiping column {}".format(x))

            for y in range(21):
                if x >= 3:
                    offset = 0x40 + x - 3
                else:
                    offset = x
                sprite[offset + y *3] = 0x00
                sprite[offset + 0x80 + y *3] = 0x00





    def convert(self):
        # raise Exception("Sorry, not implemented yet")

        # offsets in chars of the sprite "focus" chars
        # The 'F' is only 4 chars wide, I tried 5 chars, but that just was ugly
        # and also resulted in 25 chars, which wouldn't fit in 24 chars (ie
        # 8 sprites)
        focus = [0, 4, 9, 14, 19]

        # convert each "focus" char to sprites, patch 'f' later
        for idx, offset in enumerate(focus):
            result = self._to_sprites(offset)
            if idx != 0:
                self._wipe_sprite(result, 1)
            else:
                self._wipe_sprite(result ,2)
            self._sprites[idx * 0x100:(idx + 1) * 0x100] = result




    def write_sprites(self):
        with open("sprites-vertical.bin", "wb") as outfile:
            outfile.write(self._sprites)







if __name__ == '__main__':
#    koala = SpritesHandler('focus3.kla')
#    koala.reindex_colors()
#    koala.write_reindexed_koala()

    print("Converting logo to horizontal sprites ..." ,end="")
    koala = SpritesHorizontal("focus4.kla")
    koala.convert()
    koala.write_reindexed_koala()
    print("OK")

    koala.convert()
    koala.make_stretched()
    koala.write_sprites()


#    print("Converting logo to vertical sprites ...", end="")
#    koala = SpritesVertical("focus3.kla")
#    koala.convert()
#    koala.write_sprites()
#    print("OK")


