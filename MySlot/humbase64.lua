--[[

	haffman compressed spical base64 by T.G.(farmer1992@gmail.com)
	QQ 22267156
]]


local base64chars = {[0]='A',[1]='B',[2]='C',[3]='D',[4]='E',[5]='F',[6]='G',[7]='H',[8]='I',[9]='J',[10]='K',[11]='L',[12]='M',[13]='N',[14]='O',[15]='P',[16]='Q',[17]='R',[18]='S',[19]='T',[20]='U',[21]='V',[22]='W',[23]='X',[24]='Y',[25]='Z',[26]='a',[27]='b',[28]='c',[29]='d',[30]='e',[31]='f',[32]='g',[33]='h',[34]='i',[35]='j',[36]='k',[37]='l',[38]='m',[39]='n',[40]='o',[41]='p',[42]='q',[43]='r',[44]='s',[45]='t',[46]='u',[47]='v',[48]='w',[49]='x',[50]='y',[51]='z',[52]='0',[53]='1',[54]='2',[55]='3',[56]='4',[57]='5',[58]='6',[59]='7',[60]='8',[61]='9',[62]='-',[63]='_'}
local base64bytes = {['-']="111110",['_']="111111",['0']="110100",['1']="110101",['2']="110110",['3']="110111",['4']="111000",['5']="111001",['6']="111010",['7']="111011",['8']="111100",['9']="111101",['A']="000000",['a']="011010",['B']="000001",['b']="011011",['C']="000010",['c']="011100",['D']="000011",['d']="011101",['E']="000100",['e']="011110",['F']="000101",['f']="011111",['G']="000110",['g']="100000",['H']="000111",['h']="100001",['I']="001000",['i']="100010",['J']="001001",['j']="100011",['K']="001010",['k']="100100",['L']="001011",['l']="100101",['M']="001100",['m']="100110",['N']="001101",['n']="100111",['O']="001110",['o']="101000",['P']="001111",['p']="101001",['Q']="010000",['q']="101010",['R']="010001",['r']="101011",['S']="010010",['s']="101100",['T']="010011",['t']="101101",['U']="010100",['u']="101110",['V']="010101",['v']="101111",['W']="010110",['w']="110000",['X']="010111",['x']="110001",['Y']="011000",['y']="110010",['Z']="011001",['z']="110011"}

local haffman_t={[0]="00",[1]="01",[2]="100",[3]="101",[4]="1100",[5]="1101",[6]="11100",[7]="11101",[8]="111100",[9]="111101",[10]="1111100",[11]="1111101",[12]="11111100",[13]="11111101",[14]="111111100",[15]="111111101",}

-- enc begin

local function tobase64char(num)
	while string.len(num)~=6 do
		num=num.."1"
	end
	return base64chars[(tonumber(num,2))]
end

local function enc(data)

	local count_t={[1]={n="0",p=0},[2]={n="1",p=0},[3]={n="2",p=0},[4]={n="3",p=0},[5]={n="4",p=0},[6]={n="5",p=0},[7]={n="6",p=0},[8]={n="7",p=0},[9]={n="8",p=0},[10]={n="9",p=0},[11]={n="a",p=0},[12]={n="b",p=0},[13]={n="c",p=0},[14]={n="d",p=0},[15]={n="e",p=0},[16]={n="f",p=0},}
	local data_str={}

	for i=1,string.len(data) do
		n=string.byte(data,i)
		a=n%16
		b=(n-a)/16

		count_t[a+1].p=count_t[a+1].p+1
		count_t[b+1].p=count_t[b+1].p+1

		data_str[#data_str+1]=b
		data_str[#data_str+1]=a
	end

	table.sort(count_t,function(a,b) return a.p>b.p end)

	local out_str={}
	local this_haffman_t={}

	for i,v in ipairs(count_t) do
		this_haffman_t[tonumber(v.n,16)]=haffman_t[i-1]
		out_str[#out_str+1]=v.n
	end

	for i,v in ipairs(data_str) do
		data_str[i]=this_haffman_t[v]
	end

	local bin_str=table.concat(data_str)

	for i=1,string.len(bin_str),6 do
		local bin6=string.sub(bin_str,i,i+5)
		out_str[#out_str+1]=tobase64char(bin6)
	end

	return table.concat(out_str)
end

-- enc end

-- dec begin

local function readabit(s)
	local i=0
	return function()
		i=i+1
		return string.sub(s,i,i) or ""
	end
end

local function getxbit(r,h)
	local t=""
	while(r()=="1") do
		t=t.."1"
	end

	t=t.."0"..r()
	return h[t] or "X"
end

local function dec(data)

	local this_haffman_t={}

	for i=1,16 do
		this_haffman_t[haffman_t[i-1]]=(string.sub(data,i,i))
	end

	local t={}
	for i=17,string.len(data) do
		t[#t+1]=base64bytes[(string.sub(data,i,i))]
	end

	local reader=readabit(table.concat(t))

	local temp=getxbit(reader,this_haffman_t)

	local out_str={}

	while temp~="X" do
		out_str[#out_str+1]=string.char(tonumber(temp..getxbit(reader,this_haffman_t),16))
		temp=getxbit(reader,this_haffman_t)
	end

	return table.concat(out_str)
end


HumBase64={
	enc=enc,
	dec=dec,
}

