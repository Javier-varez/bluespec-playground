static int operate(int a, int b);

extern "C" void cxx_start() {
  const volatile int a = 12;
  const volatile int b = 43;
  volatile int c = 43;
  c = operate(a, b);
  static_cast<void>(c);
}

[[gnu::noinline]] static int operate(int a, int b) {
  int res = a + b + b;
  return res;
}
