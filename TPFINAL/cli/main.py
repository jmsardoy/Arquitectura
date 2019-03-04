from flask import Flask, render_template, request, redirect
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
from wtforms import SubmitField, FileField

from mips_cli import MipsCLI



app = Flask(__name__)
Bootstrap(app)
app.config['SECRET_KEY'] = 'asdasdasfg123'

port = '/dev/ttyUSB1'
cli = MipsCLI(port)

class LoadForm(FlaskForm):
    load = SubmitField("Load")

class RunForm(FlaskForm):
    run = SubmitField("Run")

class StepForm(FlaskForm):
    start = SubmitField("Start")
    step = SubmitField("Step")
    stop = SubmitField("Stop")


mem_path = '../src/testasm.mem'
with open(mem_path) as fp:
    instructions = fp.readlines()
    instructions = map(lambda x: x.replace('\n', ''), instructions)

@app.route("/", methods=['GET', 'POST'])
def home():
    load_form = LoadForm()
    run_form = RunForm()
    step_form = StepForm()
    return render_template('template.html', 
                           load_form=load_form,
                           run_form=run_form,
                           step_form=step_form,
                           mips_data=cli.mips_data)

@app.route("/load", methods=['POST'])
def load():
    load_form = LoadForm()
    if load_form.validate_on_submit():
        cli.load_instructions(instructions)
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
            cli.send_step()
        elif step_form.stop.data:
            cli.stop_step()
    return redirect('/')

if __name__ == '__main__':
    app.run()
