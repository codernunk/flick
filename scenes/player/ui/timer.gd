extends Control

func _process(_delta):
	var time: float = Level.time
	var msec = fmod(time, 1) * 100
	var seconds = fmod(time, 60)
	var minutes = fmod(time, 3600) / 60
	$Minutes.text =  "[b]%02d:[/b]" % minutes
	$Seconds.text =  "[b]%02d.[/b]" % seconds
	$Msec.text =  "[b]%03d[/b]" % msec

