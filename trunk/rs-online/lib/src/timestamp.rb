# Retorna uma string na forma ideal para o UPDATE no BD.
def timestamp time
  time.strftime("%Y/%m/%d %H:%M:%S")
end