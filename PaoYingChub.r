# Homework 2

choices = c('paper','rock','scissor')
history = list('Win' = 0, 'Lose' = 0, 'Draw' = 0)
while (T) {
  bot <- sample(choices, size=1)
  print('Q to quit game')
  print('Paper, Rock, Scissor')
  yours <- tolower(readLines('stdin', n=1))
  if (yours == 'q'){
    break
  }
  if (any(!yours %in% choices)) {
    print('Please put paper, rock or scissor')
  } else if (bot == yours){
    print('Draw')
    history$Draw = history$Draw + 1
  } else if ((bot == 'paper' & yours == 'scissor')|
             (bot == 'rock' & yours == 'paper')|
             (bot == 'scissor' & yours == 'rock')){
    print('You won!')
    history$Win = history$Win + 1
  } else {
    print('You lost')
    history$Lose = history$Lose + 1
  }
}
print('History')
print(history)
