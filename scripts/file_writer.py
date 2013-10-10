class FileWriter:
  def __init__(self, output_file = 'out.log'):
    self.output_file = output_file
    self.pending_newline = False

  def write(self, msg):
    self.do_write(msg)
    self.pending_newline = True

  def writeln(self, line):
    if self.pending_newline:
      line = "\n" + line + "\n"
      self.pending_newline = False
    else:
      line = line + "\n"

    self.do_write(line)

  def flush(self):
    log_file = self.get_log_file()
    log_file.flush()

  def close(self):
    log_file = self.get_log_file()
    log_file.close()

  def do_write(self, msg):
    log_file = self.get_log_file()
    log_file.write(msg)
    log_file.flush()

  def get_log_file(self):
    if not hasattr(self, 'log_file'):
      self.log_file = open(self.output_file, 'a')

    return self.log_file

