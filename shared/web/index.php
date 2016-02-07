<!DOCTYPE html>
<?php
//error_reporting(E_ALL);
//ini_set('display_errors', 1);

$cfg_file = "./settings.cfg";
$opts = parse_ini_file($cfg_file, false, INI_SCANNER_RAW);
$update = false;

if (!empty($_POST)) {
	if (!empty($_POST["hosttointercept"]) && preg_match("/^[a-z\.]+$/", $_POST["hosttointercept"]) && $opts["hosttointercept"] !== $_POST["hosttointercept"]) {
		$opts["hosttointercept"] = $_POST["hosttointercept"];
		$update = true;
	}
	if (!empty($_POST["loglevel"]) && preg_match("/^(Off|Normal|High)$/", $_POST["loglevel"]) && $opts["loglevel"] !== $_POST["loglevel"]) {
		$opts["prevent_atv_update"] = $_POST["loglevel"];
		$update = true;
	}
	if (empty($_POST["prevent_atv_update"]) && $opts["prevent_atv_update"] === "True") {
		$opts["prevent_atv_update"] = "False";
		$update = true;
	} elseif (!empty($_POST["prevent_atv_update"]) && $opts["prevent_atv_update"] === "False") {
		$opts["prevent_atv_update"] = "True";
		$update = true;
	}
	if (empty($_POST["enable_dnsserver"]) && $opts["enable_dnsserver"] === "True") {
		$opts["enable_dnsserver"] = "False";
		$update = true;
	} elseif (!empty($_POST["enable_dnsserver"]) && $opts["enable_dnsserver"] === "False") {
		$opts["enable_dnsserver"] = "True";
		$update = true;
	}

	if ($update) {
		$str = "[PlexConnect]\r\n";
		foreach ($opts as $key => $val) {
			$str .= "$key=$val\r\n";
		}
		file_put_contents($cfg_file, $str);
	}
}
?>
<html>
	<head>
		<meta http-equiv="expires" content="0"/>
		<script type="text/javascript" src="https://code.jquery.com/jquery-2.2.0.min.js"></script>
		<script type="text/javascript">
			$(function() {
<?php
echo "$(\"#hosttointercept\").val(\"$opts[hosttointercept]\");";
echo "$(\"#loglevel\").val(\"$opts[loglevel]\");";
echo "$(\"#prevent_atv_update\").prop(\"checked\",\"$opts[prevent_atv_update]\"===\"True\");";
echo "$(\"#enable_dnsserver\").prop(\"checked\",\"$opts[enable_dnsserver]\"===\"True\");";
if ($update) {
	echo "alert(\"Please restart PlexConnect for the changes to take effect!\");";
}
?>
			});
		</script>
		<style type="text/css">
			body {
				padding: 0.5em 0 0;
				margin: 0;
				border-top: 1px solid lightgray;
				font-family: sans-serif;
				font-size: 14px;
			}

			form {
				width: 45%;
				float: right;
				padding: 0.5em;
				margin: 0 0.5em 0.5em 0.5em;
				border: 1px solid gray;
				border-radius: 0.25em;
			}

			div {
				padding: 0 0.5em;
				box-sizing: border-box;
				padding-top: 0.5em;
			}

			h1 {
				padding: 0;
				margin: 0;
				text-align: center;
				font-size: 1.5em;
			}

			span {
				font-family: monospace;
				background: lightgray;
				padding: 0 2px;
			}

			table {
				width: 100%;
				margin-top: 1em;
			}

			th {
				text-align: center;
				font-weight: normal;
			}

			select {
				width: 100%;
			}

			ol {
				padding-left: 1em;
				margin: 1em 0;
			}

			li {
				margin-bottom: 1em;
			}
		</style>
	</head>
	<body>
		<form method="post" >
			<h1>Options</h1>
			<table>
				<tr>
					<td><label for="hosttointercept">Channel:*</label></td>
					<td>
						<select id="hosttointercept" name="hosttointercept">
							<option value="www.icloud.com" selected>iMovie Theater</option>
							<option value="trailers.apple.com">Trailers</option>
							<option value="secure.marketwatch.com">WSJ Video</option>
						</select>
					</td>
				</tr>
				<tr>
					<td><label for="loglevel">Logging:</label></td>
					<td>
						<select id="loglevel" name="loglevel">
							<option value="Off">Off</option>
							<option value="Normal" selected>Normal</option>
							<option value="High">High</option>
						</select>
					</td>
				</tr>
				<tr>
					<td><label for="prevent_atv_update">Prevent ATV Update:</label></td>
					<td><input type="checkbox" id="prevent_atv_update" name="prevent_atv_update"/></td>
				</tr>
				<tr>
					<td><label for="enable_dnsserver">Enable DNS Server:</label></td>
					<td><input type="checkbox" id="enable_dnsserver" name="enable_dnsserver"/></td>
				</tr>
				<tr>
					<th colspan="2"><input type="submit" value="Submit"/></th>
				</tr>
			</table>
		</form>
		<div>
			<h1>Certificate Installation*</h1>
			<ol>
				<li>Go to the AppleTV settings menu.</li>
				<li>Select "<b>General</b>" then scroll the cursor down to highlight "<b>Send Data To Apple</b> and set to "<b>No</b>".</li>
				<li>With "<b>Send Data To Apple</b>" highlighted, press "&#9658;&#10073;&#10073;" (not the normal "<b>Select</b>" button) and you will be prompted to add a profile.</li>
				<li>Enter (without the quotes): "<span><?php echo "http://$opts[hosttointercept]/$opts[hosttointercept].cer" ?></span>"</li>
			</ol>
		</div>
	</body>
</html>