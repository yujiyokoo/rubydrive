# rubydrive

Motorola 68000 emulator (Mega Drive) in ruby.

## Running

First, use bundler to install gems:
```
bundle install
```


Run the following command in the repo directory:
```
bundle exec ruby src/main.rb examples/minimal.bin
```

Right now, it won't have a lot of output.

To see which instructions it is running, run the following:
```
DEBUG=1 bundle exec ruby src/main.rb examples/minimal.bin
```

You should get output like this:
```
starting rubydrive...
looking at instruction word at 8: 46fc
instruction: #<struct Instruction::MOVE_TO_SR value=9984>
Instruction::MOVE_TO_SR
looking at instruction word at c: 4e71
instruction: #<struct Instruction::NOP>
Instruction::NOP
looking at instruction word at e: 4e71
instruction: #<struct Instruction::NOP>
Instruction::NOP
looking at instruction word at 10: 4a79
instruction: #<struct Instruction::TST target=#<struct Target::Absolute address=0>, size=2>
Instruction::TST
looking at instruction word at 16: 4e72
instruction: #<struct Instruction::STOP value=9984>
Instruction::STOP
rubydrive finished
```

This is a really 'minimal' ROM I have prepared. Bigger, ROMS will be added later on.

## Testing

Tests can be run with:
```
bundle exec rake test
```


