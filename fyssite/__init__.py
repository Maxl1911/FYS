import os
import subprocess
from flask import Flask
from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for
)
from db2 import *
def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True, template_folder='templates')
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

#########################################
#            Multimedia page            #
#########################################   
    @app.route('/')
    def index():
        user = session.get('user_id')
        if user == None:
            return redirect("/login")
        return render_template ('multimedia/index.html',user = user)

#########################################
#            login page                 #
######################################### 

    @app.route('/login', methods=('GET', 'POST'))
    def login():
        if request.method == 'POST': # if the methoode is not post reload the login page
            password = request.form['username'] #Gets the ticket number form the HTML form with the name: username
            surname = request.form['password'] #Gets the surname form the HTML form with the name: password

            #### Defining some variables ####
      
            error = "Please enter an falid Ticked number and surname" #error message when the ticketnumber and surname dosnt macht the input 


            user = surname # copying the variable surname to the variable user to be later used in the login check

            #### DEBUG INFO ####
            print(f"DEBUG INFO: surname:{surname} user:{user} password:{password}") # prints debugging info into the log file


            #########################################
            #            Authentication             #
            ######################################### 

            # Check if the variables are enmpty if that is so reload the page
            if surname and password != None:
                passwd = db(surname) # Call the function bd form the file db2.py and gives the variable surname to the function
                # if the the ticketnumber is the same as the filled in number and check if the filled in surename is the smame as the one in the database
                if surname == user and password == passwd:
                    session.clear() #clear the session cookie
                    session['user_id'] = surname # makes an session cookie and store the surname in it.
                    ip = request.remote_addr
                    os.system(f'sudo ipset add whitelist {ip}')
                    print(ip)
                    print("GOED")
                    return redirect("/landing")
                else:
                    print(f"DEBUG INFO: surname:{surname} user:{user} password:{password} passwd:{passwd}")
                    print(type(password))
                    print(type(passwd))
                    return render_template ('login/login.html', error = error) # if the if stamets fails rerender the login page with an error
            else:
                print("LEEEEG")
                return redirect("/login")
        return render_template ('login/login.html')

#########################################
#            landings page              #
######################################### 
    @app.route('/landing', methods=('GET', 'POST'))
    def landing():
        user = session.get('user_id')
        if user == None:
            return redirect("/login")
        return render_template ('landing/landig.html',user = user)

    @app.route('/logout')
    def logout():
        session.clear()
        ip = request.remote_addr
        os.system(f'sudo ipset del whitelist {ip}')
        return redirect(url_for('login'))  
    return app
