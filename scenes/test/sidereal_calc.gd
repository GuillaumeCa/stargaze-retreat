extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var lat = float($Lat.text)
	var long = float($Long.text)
	var ra = float($RA.text)
	var dec = float($DEC.text)
	var date = $Date.text
	
	var alt_az = adjust_ra_dec(ra, dec, date, long, lat)
	$Result.text = "Alt: " + str(rad_to_deg(alt_az.x)) + " Az: " + str(rad_to_deg(alt_az.y))

## Calculate the alt + az in radians based on ra/dec and long/lat in degrees
func adjust_ra_dec(ra: float, dec: float, date: String, long: float, lat: float) -> Vector2:
	var unix_time_j2000 = Time.get_unix_time_from_datetime_string("2000-01-01T00:00:00")
	var unix_time = Time.get_unix_time_from_datetime_string(date)
	
	#var julian_time = (unix_time / 86400) + 2440587.5
	#$ResultDebug.text += "\njulian time: " + str(julian_time)
	#var gmst = fmod(18.697374558+24.06570982441908 * (julian_time - 2451545.0), 24)
	#prints("gmst", gmst)
	
	
	var days = (unix_time-unix_time_j2000) / 86400.0
	
	var time_dict = Time.get_datetime_dict_from_unix_time(unix_time)
	var ut = time_dict.get("hour") + (time_dict.get("minute") / 60.0)
	
	var lst = 100.46 + (0.985647 * days) + long + (15 * ut)
	# make sure lst is in the range 0 to 360 degrees
	if lst < 0:
		lst = lst + 360
	
	var ha = lst - ra
	
	var dec_d = deg_to_rad(dec)
	var lat_d = deg_to_rad(lat)
	var ha_d = deg_to_rad(ha)
	
	
	var alt = sin(dec_d) * sin(lat_d) + cos(dec_d) * cos(lat_d) * cos(ha_d)
	alt = asin(alt)
	var az = (sin(dec_d) - (sin(alt) * sin(lat_d))) / (cos(alt) * cos(lat_d))
	az = acos(az)
	
	if sin(ha_d) >= 0:
		az = 2*PI - az
	
	return Vector2(alt, az)

