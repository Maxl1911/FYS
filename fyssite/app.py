import os
from flask import Flask
from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for
)
def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

# route to index page    
    @app.route('/')
    def index():
        user = session.get('user_id')
        if user == None:
            return redirect("/login")
        return render_template ('multimedia/index.html',user = user)

    @app.route('/login', methods=('GET', 'POST'))
    def login():
        if request.method == 'POST':
            username = request.form['username']
            password = request.form['password']
            error = "Please enter an falid Ticked number and surname"
            user= "testuser"
            passwd = "pass"
            if username and password != None:
                if username == user and password == passwd:
                    session.clear()
                    session['user_id'] = username
                    return redirect("/landing")
                else:
                    return render_template ('Login/login.html', error = error)
            else:
                 return redirect("/login")
            
        return render_template ('login/login.html')

    @app.route('/landing', methods=('GET', 'POST'))
    def landing():
        user = session.get('user_id')
        if user == None:
            return redirect("/login")
        return render_template ('Landing/landig.html',user = user)

    @app.route('/logout')
    def logout():
        session.clear()
        return redirect(url_for('login'))  
    return app
