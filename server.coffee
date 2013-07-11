# Just started the code. 

express = require 'express'
app = express()
uuid = require 'node-uuid'
util = require 'util'
mysql = require 'mysql'
connection = mysql.createConnection({
	host     : 'localhost',
	user     : 'root',
	password : 'sohail2155',
	database : 'coupon-world'
})

#app.use express.bodyParser()

# Home root route
app.get '/', (req, res) ->
  res.end '<a href="/radeem/1/10">Click here to redeem coupon</a>'

# Radeem Coupon
app.get '/radeem/:campaign/:value', (req, res) ->
	connection.connect()
	params = req.params
	# Can replace raw string to be via formation (like below)
	connection.query 'select * from campaigns where campaign_id = '+params.campaign+' and coupon_value = '+params.value+' LIMIT 1', (err, rows, fields) ->
		if err 
			throw err
		
		# Found campaign.
		if rows.length > 0
			campaign = rows[0]
			cCode = couponCode(16)
			console.log cCode
			# Instead of RemoteAddr, we can scan for XFF
			sql = util.format "INSERT INTO `coupons` (`uuid`,`host_ip`,`campaign_id`,`coupon_code`,`cre_stamp`) VALUES ('%s', '%s', %d, '%s', '%s')", uuid.v1(), req.connection.remoteAddress, campaign.campaign_id, cCode, (new Date()).getTime()
			# SQL is build. lets insert
			connection.query sql, (err, rows) ->
				if err
					throw err	
					
				res.send 'Your Coupon Code is: ' + cCode
		else
			res.send 'Sorry, Invalid Campaign Id'

# l means length of coupon code.
couponCode = (l) ->
  range = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  coupon = ''
  j = 0
  # While my coupon isn't 16 char long.
  while j < l
    coupon += range.charAt Math.floor(Math.random() * range.length)
    j++

  return coupon

app.listen 3000

console.log 'listening at 3000'
