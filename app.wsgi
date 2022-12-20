import sys
sys.path.insert(0, '/var/www/fyssite')

activate_this = '/home/max/.local/share/virtualenvs/max-74J2BvZz/bin/activate_this.py'
with open(activate_this) as file_:
    exec(file_.read(), dict(__file__=activate_this))

from __init__ import create_app
application = create_app()
