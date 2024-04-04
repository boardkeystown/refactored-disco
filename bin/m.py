print("from python")
times_called = 0
def call_function():
    global times_called
    print("hello from python!!!")
    times_called += 1
    print(f'{times_called=}')
if __name__ == '__main__':
    pass