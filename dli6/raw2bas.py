import os
import sys
import click

class Script:

    def __init__(self, name):
        self.buffer = []
        self.lineno = 10
        self.add(f"REM {name}")

    def add(self, line):
        self.buffer.append(f"{self.lineno} {line.upper()}")
        self.lineno += 10

    def __str__(self):
        return "\n".join(self.buffer) + "\n"

class Loader(Script):

    def __init__(self, name, addr, binary):
        super().__init__(name)
        self.binary = binary
        self.start = addr
        self.end = self.start + len(self.binary) - 1
        self.base()
        self.data()

    def base(self):
        self.add(f"for x={self.start} to {self.end}")
        self.add("read d")
        self.add("poke x, d")
        self.add("next x")
        self.add(f"z = usr({self.start})")

    def data(self,w=8):
        for i in range(0, len(self.binary), w):
            t = [f"{int(i)}" for i in self.binary[i:i+w]]
            self.add(f"data {','.join(t)}")

@click.command()
@click.option('--strip-header', default=12, help='Strip obx header')
@click.option('--start-addr', default=1536, help='Start address')
@click.option('--filename', help='Object filename')
def main(strip_header, start_addr, filename):
    outfile = f"{os.path.splitext(filename)[0]}.bas"
    binary = open(filename, "rb").read()
    if strip_header:
        binary = binary[strip_header:]
    s = Loader(name=outfile, addr=start_addr, binary=binary)
    print(f"Write {outfile}")
    open(outfile, "w").write(str(s))

if __name__ == '__main__':
    main()
