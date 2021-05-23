import os

shape_path = './main/data/shape/'
image_path = './main/data/image/'
sound_path = './main/data/sound/'

with open('./main/data/shape_list.conf', 'w+') as f:
    for i in os.listdir(shape_path):
        f.write(f'{i}\n')

with open('./main/data/image_list.conf', 'w+') as f:
    for i in os.listdir(image_path):
        f.write(f'{i}\n')

with open('./main/data/sound_list.conf', 'w+') as f:
    for i in os.listdir(sound_path):
        f.write(f'{i}\n')