from subprocess import call
import os

from flask import Flask, render_template, request, redirect
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
from flask_wtf.file import FileField
from wtforms import SubmitField, FileField, IntegerField

from mips_cli import MipsCLI
from ensamblador.masm import Masm



app = Flask(__name__)
Bootstrap(app)
app.config['SECRET_KEY'] = 'asdasdasfg123'

port = '/dev/ttyUSB1'
cli = MipsCLI(port)

class LoadForm(FlaskForm):
    load = SubmitField("Load")
    asmfile = FileField("Asmfile")

class RunForm(FlaskForm):
    run = SubmitField("Run")

class StepForm(FlaskForm):
    start = SubmitField("Start")
    nsteps = IntegerField("n", default=1)
    step = SubmitField("Step")
    stop = SubmitField("Stop")


"""
mem_path = '../src/testasm.mem'
with open(mem_path) as fp:
    instructions = fp.readlines()
    instructions = map(lambda x: x.replace('\n', ''), instructions)
"""
last_nsteps = 1

@app.route("/", methods=['GET', 'POST'])
def home():
    load_form = LoadForm()
    run_form = RunForm()
    step_form = StepForm()
    step_form.nsteps.default = last_nsteps
    step_form.process()
    return render_template('template.html', 
                           load_form=load_form,
                           run_form=run_form,
                           step_form=step_form,
                           mips_data=cli.mips_data)

@app.route("/load", methods=['POST'])
def load():
    load_form = LoadForm()
    if load_form.validate_on_submit():
        asmfile = request.files[load_form.asmfile.name].read()
        asmfile_path = 'tempfiles/asmfile.asm'
        open(asmfile_path, "w").write(asmfile)
        exit_code = call("ensamblador/assembler.py tempfiles/asmfile.asm tempfiles/asmfile.mem", shell=True)
        if exit_code == 0:
            with open('tempfiles/asmfile.mem') as fp:
                instructions = fp.readlines()
                instructions = map(lambda x: x.replace('\n', ''), instructions)
            cli.load_instructions(instructions)
            os.remove('tempfiles/asmfile.asm')
            os.remove('tempfiles/asmfile.mem')
    return redirect('/')

@app.route("/run", methods=['POST'])
def run():
    run_form = RunForm()
    if run_form.validate_on_submit():
        cli.run()
    return redirect('/')

@app.route("/step", methods=['POST'])
def step():
    step_form = StepForm()
    if step_form.validate_on_submit():
        if step_form.start.data:
            cli.start_step()
        elif step_form.step.data:
            global last_nsteps
            last_nsteps = step_form.nsteps.data
            cli.send_step(nsteps=step_form.nsteps.data)
        elif step_form.stop.data:
            cli.stop_step()
    return redirect('/')

if __name__ == '__main__':
    app.run()
