        ��  ��                  k  @   D W S J S R T L   S P R I N T F _ J S       0         /**
sprintf() for JavaScript 0.7-beta1
http://www.diveintojavascript.com/projects/javascript-sprintf

Copyright (c) Alexandru Marasteanu <alexaholic [at) gmail (dot] com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of sprintf() for JavaScript nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Alexandru Marasteanu BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

var sprintf = (function() {
	function get_type(variable) {
		return Object.prototype.toString.call(variable).slice(8, -1).toLowerCase();
	}
	function str_repeat(input, multiplier) {
		for (var output = []; multiplier > 0; output[--multiplier] = input) {/* do nothing */}
		return output.join('');
	}

	var str_format = function() {
		if (!str_format.cache.hasOwnProperty(arguments[0])) {
			str_format.cache[arguments[0]] = str_format.parse(arguments[0]);
		}
		return str_format.format.call(null, str_format.cache[arguments[0]], arguments);
	};

	str_format.format = function(parse_tree, argv) {
		var cursor = 1, tree_length = parse_tree.length, node_type = '', arg, output = [], i, k, match, pad, pad_character, pad_length;
		for (i = 0; i < tree_length; i++) {
			node_type = get_type(parse_tree[i]);
			if (node_type === 'string') {
				output.push(parse_tree[i]);
			}
			else if (node_type === 'array') {
				match = parse_tree[i]; // convenience purposes only
				if (match[2]) { // keyword argument
					arg = argv[cursor];
					for (k = 0; k < match[2].length; k++) {
						if (!arg.hasOwnProperty(match[2][k])) {
							throw(sprintf('[sprintf] property "%s" does not exist', match[2][k]));
						}
						arg = arg[match[2][k]];
					}
				}
				else if (match[1]) { // positional argument (explicit)
					arg = argv[match[1]];
				}
				else { // positional argument (implicit)
					arg = argv[cursor++];
				}

				if (/[^s]/.test(match[8]) && (get_type(arg) != 'number')) {
					throw(sprintf('[sprintf] expecting number but found %s', get_type(arg)));
				}
				switch (match[8]) {
					case 'b': arg = arg.toString(2); break;
					case 'c': arg = String.fromCharCode(arg); break;
					case 'd': arg = String(parseInt(arg, 10)); if (match[7]) { arg = str_repeat('0', match[7]-arg.length)+arg } break;
					case 'e': arg = match[7] ? arg.toExponential(match[7]) : arg.toExponential(); break;
					case 'f': arg = match[7] ? parseFloat(arg).toFixed(match[7]) : parseFloat(arg); break;
					case 'o': arg = arg.toString(8); break;
					case 's': arg = ((arg = String(arg)) && match[7] ? arg.substring(0, match[7]) : arg); break;
					case 'u': arg = Math.abs(arg); break;
					case 'x': arg = arg.toString(16); break;
					case 'X': arg = arg.toString(16).toUpperCase(); break;
				}
				arg = (/[def]/.test(match[8]) && match[3] && arg >= 0 ? '+'+ arg : arg);
				pad_character = match[4] ? match[4] == '0' ? '0' : match[4].charAt(1) : ' ';
				pad_length = match[6] - String(arg).length;
				pad = match[6] ? str_repeat(pad_character, pad_length) : '';
				output.push(match[5] ? arg + pad : pad + arg);
			}
		}
		return output.join('');
	};

	str_format.cache = {};

	str_format.parse = function(fmt) {
		var _fmt = fmt, match = [], parse_tree = [], arg_names = 0;
		while (_fmt) {
			if ((match = /^[^\x25]+/.exec(_fmt)) !== null) {
				parse_tree.push(match[0]);
			}
			else if ((match = /^\x25{2}/.exec(_fmt)) !== null) {
				parse_tree.push('%');
			}
			else if ((match = /^\x25(?:([1-9]\d*)\$|\(([^\)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?([b-fosuxX])/.exec(_fmt)) !== null) {
				if (match[2]) {
					arg_names |= 1;
					var field_list = [], replacement_field = match[2], field_match = [];
					if ((field_match = /^([a-z_][a-z_\d]*)/i.exec(replacement_field)) !== null) {
						field_list.push(field_match[1]);
						while ((replacement_field = replacement_field.substring(field_match[0].length)) !== '') {
							if ((field_match = /^\.([a-z_][a-z_\d]*)/i.exec(replacement_field)) !== null) {
								field_list.push(field_match[1]);
							}
							else if ((field_match = /^\[(\d+)\]/.exec(replacement_field)) !== null) {
								field_list.push(field_match[1]);
							}
							else {
								throw('[sprintf] huh?');
							}
						}
					}
					else {
						throw('[sprintf] huh?');
					}
					match[2] = field_list;
				}
				else {
					arg_names |= 2;
				}
				if (arg_names === 3) {
					throw('[sprintf] mixing positional and named placeholders is not (yet) supported');
				}
				parse_tree.push(match);
			}
			else {
				throw('[sprintf] huh?');
			}
			_fmt = _fmt.substring(match[0].length);
		}
		return parse_tree;
	};

	return str_format;
})();
 �  P   D W S J S R T L   F O R M A T D A T E T I M E _ J S         0         function FormatDateTime(fmt, v, u) {
   function pad2(v) { return (v<10)?"0"+v:v; };
   function pad3(v) { return (v<100)?"0"+pad2(v):v; };
   var res="", i=0, c, tok, wasHour, prevWasHour=0, p, dt;
   v = Math.round((v-25569)*864e5);
   dt = new Date(v);
   if ((u||$TZ) === 1) {
     dt = new Date(v - dt.getTimezoneOffset()*60000);
   } 
   if (!(dt instanceof Date && isFinite(dt))) return "Invalid Date";
   while (i<fmt.length) {
      c=fmt.charAt(i);
      tok="";
      do {
         tok+=c;
         i++;
      } while (fmt.charAt(i)===c);
	  wasHour=0;
      switch (tok.toLowerCase()) {
         case "d": res+=(dt.getUTCDate()); break;
         case "dd": res+=pad2(dt.getUTCDate()); break;
         case "ddd": res+=$fmt.ShortDayNames[dt.getUTCDay()]; break;
         case "dddd": res+=$fmt.LongDayNames[dt.getUTCDay()]; break;
         case "m": 
			if (prevWasHour) {
				res+=dt.getUTCHours();
			} else {
				res+=dt.getUTCMonth()+1; 
			};
			break;
         case "mm": 
			if (prevWasHour) {
				res+=pad2(dt.getUTCHours());
			} else {
				res+=pad2(dt.getUTCMonth()+1); 
			};
			break;
         case "mmm": res+=$fmt.ShortMonthNames[dt.getUTCMonth()]; break;
         case "mmmm": res+=$fmt.LongMonthNames[dt.getUTCMonth()]; break;
         case "yy": res+=pad2(dt.getUTCFullYear()%100); break;
         case "yyyy": res+=dt.getUTCFullYear(); break;
         case "h": res+=dt.getUTCHours(); wasHour=1; break;
         case "hh": res+=pad2(dt.getUTCHours()); wasHour=1; break;
         case "n": res+=dt.getUTCMinutes(); break;
         case "nn": res+=pad2(dt.getUTCMinutes()); break;
         case "s": res+=dt.getUTCSeconds(); break;
         case "ss": res+=pad2(dt.getUTCSeconds()); break;
         case "z": res+=dt.getUTCMilliseconds(); break;
         case "zzz": res+=pad3(dt.getUTCMilliseconds()); break;
         default: res+=tok;
      }
	  prevWasHour=wasHour;
   }
   return res;
}
   T   D W S J S R T L   S T R T O D A T E T I M E D E F _ J S         0         function strToDateTimeDef(fmt, str_dt, def, utc) {
	var year=0, month=0, day=0, hours=0, minutes=0, seconds=0, msec=0,
		i=0, j, p=0, c, tok, value, prevWasHour=0, wasHour=0, d=0;
	while (i<fmt.length) {
		c=fmt.charCodeAt(i);
		tok="";
		value=0;
		do {
			tok += fmt[i];
			d = str_dt.charCodeAt(p);
			if (d>=0x30 && d<=0x39) {
				value = value*10 + d - 0x30;
			} else {
				value = -1;
			}
			i++;
			p++;
		} while (fmt.charCodeAt(i)===c);
		tok = tok.toLowerCase();
		var digits = {'m':1,'d':1,'h':1,'n':1,'s':1,'z':2,'yy':2}[tok];
		while (digits>0 && p<str_dt.length) {
			d = str_dt.charCodeAt(p);
			if (d<0x30 || d>0x39) break;
			value = value*10 + d - 0x30;
			p++;
			digits--;
		}

		wasHour=0;
		switch (tok) {
			case "d": case "dd": day=value; break;
			case "ddd":
				j=0;
				while (j<$fmt.hortDayNames.length) {
					if (str_dt.indexOf($fmt.ShortDayNames[j], 0) > 0) {
						p += $fmt.ShortDayNames[j].length - 3;
						break;
					}
					j++;
				}
				break;
			case "dddd":
				j=0;
				while (j<$fmt.LongDayNames.length) {
					if (str_dt.indexOf($fmt.LongDayNames[j],0) > 0){
						p += $fmt.LongDayNames[j].length - 4;
						break;
					}
					j++;
				}
				break;
			case "m": case "mm":
				if (prevWasHour) { 
					minutes=value 
				} else {
					month=value
				}
				break;
			case "mmm":
				j=0;
				while (j<$fmt.ShortMonthNames.length) {
					if (str_dt.indexOf($fmt.ShortMonthNames[j],0) > 0) {
						month=j+1;
						p += $fmt.ShortMonthNames[j].length - 3;
						break;
					}
					j++;
				}
				break;
			case "mmmm":
				j=0;
				while(j<$fmt.LongMonthNames.length){
					if (str_dt.indexOf($fmt.LongMonthNames[j],0) > 0) {
						month=j+1;
						p += $fmt.LongMonthNames[j].length - 4;
						break;
					}
					j++;
				}
				break;
			case "yy": case "yyyy": year=value; break;
			case "h": case "hh": hours=value; wasHour=1; break;
			case "n": case "nn": minutes=value; break;
			case "s": case "ss": seconds=value; break;
			case "z": case "zzz": msec=value; break;
			default:
				var l = tok.length;
				value = str_dt.substring(p-l,p-l+l);
				if (tok!=="?" && tok!=="??" && tok!=="???" && tok!=value) return def;
				wasHour=prevWasHour;
		}
		prevWasHour=wasHour;
	}
	if ((day | month | year) !== 0) {
		var dt;
		if ((utc||$TZ)==2) {
			dt=Date.UTC(year, month-1, day, hours, minutes, seconds, msec)
		} else {
			dt=new Date(year, month-1, day, hours, minutes, seconds, msec).getTime()
		}
		return isNaN(dt) ? def : dt/864e5+25569;
	} else {
		if ( hours>=0 && hours<24 && minutes>=0 && minutes<60 && seconds>=0 && seconds<60 && msec>=0 && msec<1000 ) {
			return (hours+(minutes+(seconds+msec*0.001)/60)/60)/24
		} else {
			return def;
		}
	}
}
   :  <   D W S J S R T L   A L E A _ J S         0         /*

Copyright (C) 2010 by Johannes Baag�e <baagoe@baagoe.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

From http://baagoe.com/en/RandomMusings/javascript/
*/
function $alea() {
  return (function(args) {
    // Johannes Baagøe <baagoe@baagoe.com>, 2010
    var s0 = 0;
    var s1 = 0;
    var s2 = 0;
    var c = 1;

    if (args.length == 0) {
      args = [+new Date];
    }
    var mash = function() {
       var n = 0xefc8249d;
    
       var mash = function(data) {
         data = data.toString();
         for (var i = 0; i < data.length; i++) {
           n += data.charCodeAt(i);
           var h = 0.02519603282416938 * n;
           n = h >>> 0;
           h -= n;
           h *= n;
           n = h >>> 0;
           h -= n;
           n += h * 0x100000000; // 2^32
         }
         return (n >>> 0) * 2.3283064365386963e-10; // 2^-32
       };
    
       //mash.version = 'Mash 0.9';
       return mash;
    }();
    s0 = mash(' ');
    s1 = mash(' ');
    s2 = mash(' ');

    for (var i = 0; i < args.length; i++) {
      s0 -= mash(args[i]);
      if (s0 < 0) {
        s0 += 1;
      }
      s1 -= mash(args[i]);
      if (s1 < 0) {
        s1 += 1;
      }
      s2 -= mash(args[i]);
      if (s2 < 0) {
        s2 += 1;
      }
    }
    mash = null;

    var random = function() {
      var t = 2091639 * s0 + c * 2.3283064365386963e-10; // 2^-32
      s0 = s1;
      s1 = s2;
      return s2 = t - (c = t | 0);
    };
    /*random.uint32 = function() {
      return random() * 0x100000000; // 2^32
    };
    random.fract53 = function() {
      return random() +
        (random() * 0x200000 | 0) * 1.1102230246251565e-16; // 2^-53
    };*/
    //random.version = 'Alea 0.9';
    random.args = args;
    return random;

  } (Array.prototype.slice.call(arguments)));
};  �  L   D W S J S R T L   U N I C H A R C O D E A T _ J S       0         // inspired from 
// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/String/charCodeAt
function $uniCharCodeAt(str, idx) {
    var c = str.charCodeAt(idx);
    if (0xD800 <= c && c <= 0xDBFF) { // High surrogate
        var lo = str.charCodeAt(idx+1);
        if (isNaN(lo)) return c;
        return ((c - 0xD800) * 0x400) + (lo - 0xDC00) + 0x10000;
    }
    if (0xDC00 <= c && c <= 0xDFFF) { // Low surrogate
        return -1;
    }
    return c;
}   �  D   D W S J S R T L   U N I C H A R A T _ J S       0         // inspired from 
// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/String/charCodeAt
function $uniCharAt(str, idx) {
    var c = str.charCodeAt(idx);
    if (0xD800 <= c && c <= 0xDBFF) { // High surrogate
        return str.substr(idx, 2);
    }
    if (0xDC00 <= c && c <= 0xDFFF) { // Low surrogate
        return null;
    }
    return str.charAt(idx);
}