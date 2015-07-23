function Vector(x,y,z)
	local vector = {}
	local t = GetOrigin(x)
	vector.x = t and t.x or z and x or x.x
	vector.y = t and t.y or y or x.y
	vector.z = t and t.z or z or x.z
	vector.clone = function() return Vector(vector.x, vector.y, vector.z) end
	vector.unpack = function() return vector.x, vector.y, vector.z end
	vector.len = function() return math.sqrt(vector.len2(v)) end
	vector.len2 = function(v) v = v or vector return vector.x*v.x + vector.y*v.y + vector.z*v.z end
	vector.dist = function(v) local a = vector-v return a.len() end
	vector.normalize = function() local a = vector.len() vector.x = vector.x/a vector.y = vector.y/a vector.z = vector.z/a end
	vector.normalized = function() local a = vector.clone() a.normalize() return a end
	vector.rotate = function(phiX, phiY, phiZ) end
	vector.rotated = function(phiX, phiY, phiZ) end
	vector.projectOn = function(v) end
	vector.mirrorOn = function(v) end
	vector.center = function(v) end
	vector.crossP = function() end
	vector.dotP = function() end
	vector.polar = function() end
	vector.angleBetween = function(v1, v2) end
	vector.compare = function(v) end
	vector.perpendicular = function() end
	vector.perpendicular2 = function() end
	local vectorOperations = {
		__type = function() return "Vector" end,
		__add = function(v1, v2) return Vector(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z) end,
		__sub = function(v1, v2) return Vector(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z) end,
		__mul = function(a, b) return (type(a) == "number" and type(b) == "Vector") and Vector(b.x*a, b.y*a, b.z*a) or (type(a) == "Vector" and type(b) == "number") and Vector(a.x*b, a.y*b, a.z*b) or a.dotP(b) end,
		__div = function(a, b) return (type(a) == "number" and type(b) == "Vector") and Vector(a/b.x, a/b.y, a/b.z) or (type(a) == "Vector" and type(b) == "number") and Vector(b.x/a, b.y/a, b.z/a) or MessageBox(0,"div operation","vector.lua",0) end,
		__eq  = function(v) return vector.x == v.x and vector.y == v.y and vector.z == v.z end
		__tostring = function() return "Vector("..vector.x..", "..vector.y..", "..vector.z..")" end
	}
	setmetatable(vector, vectorOperations)
	return vector
end