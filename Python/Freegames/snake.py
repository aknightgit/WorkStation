"""Snake, classic arcade game.

Exercises

1. How do you make the snake faster or slower?
2. How can you make the snake go around the edges?
3. How would you move the food?
4. Change the snake to respond to arrow keys.

"""

from turtle import *
from random import randrange
from freegames import square, vector

food = vector(0, 0)
snake = [vector(10, 0),vector(10, -10)]   ## a snake, 2block at least!!
aim = vector(0, -10)
speed_ms = 500
foodcnt = 1

def change(x, y):
    "Change snake direction."
    aim.x = x if aim.x+x!=0 else aim.x ## do not allow turning back!!!
    aim.y = y if aim.y+y!=0 else aim.y

def inside(head):
    "Return True if head inside boundaries."
    return -200 < head.x < 190 and -200 < head.y < 190

def move():
    "Move snake forward one segment."
    global foodcnt      ## 针对变量，需要定义为global变量，修改值。 为啥其他的 vector list不需要？
    global speed_ms
    foodcnt += 1
    head = snake[-1].copy()
    head.move(aim)          ##这个是vector自带的method

    if not inside(head) or head in snake:
        square(head.x, head.y, 9, 'red')
        update()
        return

    snake.append(head)

    if head == food:
        print('Snake:{} Speed:{} Interval: {}'.format(len(snake), min(int(len(snake)/10)+1,7), speed_ms))  ## speed rate 1-7
        food.x = randrange(-19, 19) * 10
        food.y = randrange(-19, 19) * 10
        while food in snake:
            food.x = randrange(-19, 19) * 10
            food.y = randrange(-19, 19) * 10
    else:
        snake.pop(0)

    clear()

    for body in snake:
        square(body.x, body.y, 9, 'black')

    speed_ms=max(400-int((len(snake))/10) * 50,100)   ## speed from 500 - 100
    if foodcnt % 2 :
        square(food.x, food.y, 9, 'green')
    else:
        square(food.x, food.y, 9, 'white')  ## food is shinning
    update()
    ontimer(move, speed_ms)



setup(420, 420, 370, 0)
hideturtle()
tracer(False)
listen()
onkey(lambda: change(10, 0), 'Right')
onkey(lambda: change(-10, 0), 'Left')
onkey(lambda: change(0, 10), 'Up')
onkey(lambda: change(0, -10), 'Down')
move()
done()
