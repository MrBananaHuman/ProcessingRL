import socket
import tensorflow as tf
import numpy as np
import random
import math
import os


HOST = '127.0.0.1'
PORT = 3030
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)
conn, addr = s.accept()
print('Connected by', addr)


epsilon = 1
epsilon_minimum_value = 0.001
n_actions = 3		# Left / Stay / Right
max_number_of_games = 0
n_states = 2		# ball.x / agent.x
discount = 0.9
learning_rate = 2e-6
hiddenSize = 50
batch_size = 50
epoch = 1001

X = tf.placeholder(tf.float32, [None, n_states])	# input state

W1 = tf.Variable(tf.truncated_normal([n_states, hiddenSize], stddev=1.0 / math.sqrt(float(n_states))))
b1 = tf.Variable(tf.truncated_normal([hiddenSize], stddev=0.01))  

input_layer = tf.nn.relu(tf.matmul(X, W1) + b1)
W2 = tf.Variable(tf.truncated_normal([hiddenSize, hiddenSize],stddev=1.0 / math.sqrt(float(hiddenSize))))
b2 = tf.Variable(tf.truncated_normal([hiddenSize], stddev=0.01))

hidden_layer = tf.nn.relu(tf.matmul(input_layer, W2) + b2)
W3 = tf.Variable(tf.truncated_normal([hiddenSize, n_actions],stddev=1.0 / math.sqrt(float(hiddenSize))))
b3 = tf.Variable(tf.truncated_normal([n_actions], stddev=0.01))

output_layer = tf.matmul(hidden_layer, W3) + b3

Y = tf.placeholder(tf.float32, [None, n_actions])	# output actions
cost = tf.reduce_sum(tf.square(Y-output_layer)) / (2 * batch_size)
#cost = tf.reduce_mean(tf.square(Y-output_layer))
optimizer = tf.train.GradientDescentOptimizer(learning_rate).minimize(cost)

def randf(s, e):
 return (float(random.randrange(0, (e - s) * 9999)) / 10000) + s;

def get_state():
 state = conn.recv(1024).decode()
 #print(state)
 if not state:
  return null
 return str(state)	# gameNumber / reward / ball.x / ball.y / agent.x

def send_action(action_number):
 conn.send(str(action_number).encode())
 
def close_connection():
 conn.close()

def cal_reward(ball_x, agent_x):
 diff = abs(ball_x - agent_x)
 return (580-diff) / 580

def main(_):
 conn.send(str(-1).encode())
 saver = tf.train.Saver()

 winCount = 0
 with tf.Session() as sess:   
  tf.initialize_all_variables().run()

  current_game_num = 0
  print('all ready!')
  x_inputs = np.zeros((batch_size, n_states))
  targets = np.zeros((batch_size, n_actions))
  step_counter = 0
  for i in range(epoch):
   err = 0
   isGameOver = False
   while(current_game_num == i):
    action = -9999
    current_state = get_state().split('/')	# gameNumber / reward / ball.x / ball.y / agent.x
    current_game_num = int(current_state[0])
    x_inputs[step_counter, 0] = int(current_state[2])
    x_inputs[step_counter, 1] = int(current_state[4])

    current_input = np.zeros((1, n_states))
    current_input[0, 0] = int(current_state[2])
    current_input[0, 1] = int(current_state[4])
  
    global epsilon
    nextStateMaxQ = 0
    q = sess.run(output_layer, feed_dict={X: current_input})
    index = q.argmax()

    if (randf(0, 1) <= epsilon):
     action = random.randrange(1, n_actions+1)
    else:          
     action = index + 1 
    if (epsilon > epsilon_minimum_value):
     epsilon = epsilon * 0.999
    
    send_action(action)
    next_state = get_state().split('/')
    next_input = np.zeros((1, n_states))
    next_input[0, 0] = int(next_state[2])
    next_input[0, 1] = int(next_state[4])

    next_outputs = sess.run(output_layer, feed_dict={X: next_input})
    nextStateMaxQ = np.amax(next_outputs)
    send_action(-1)

    reward = cal_reward(int(next_state[2]), int(next_state[4]))
    
    if reward < 0.98:
     targets[step_counter, int(action-1)] = -1
    else:
     targets[step_counter, int(action-1)] = 1 + discount * nextStateMaxQ

    if step_counter < batch_size-1:
     step_counter += 1
    else:
     step_counter = 0
     _, loss = sess.run([optimizer, cost], feed_dict={X: x_inputs, Y: targets})
     print("GameSteps: " + str(i) + ": loss: " + str(loss))
     x_inputs = np.zeros((batch_size, n_states))
     targets = np.zeros((batch_size, n_actions))

  save_path = saver.save(sess, os.getcwd()+"/model.ckpt")
  print("Model saved in file: %s" % save_path)

if __name__ == '__main__':
 tf.app.run()
   































