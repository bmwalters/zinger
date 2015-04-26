function math.sign(num)
	if num < 0 then
		return -1
	elseif num > 0 then
		return 1
	end

	return 0
end

function math.EaseOutElastic(t, a, p)
	return 1 - math.EaseInElastic(1 - t, a, p)
end

function math.EaseInElastic(t, a, p)
	local s

	p = p or 0.45

	if t <= 0 or t >= 1 then
		return t
	end

	if (not a) or a < 1 then
		a = 1
		s = p / 4
	else
		s = p / (2 * math.pi) * math.asin(1 / a)
	end

	t = t - 1

	return -(a * math.pow(2, 10 * t) * math.sin((t - s) * (2 * math.pi) / p))
end

function math.EaseInOutElastic(t, a, p)
	if t < 0.5 then
		return 0.5 * math.EaseInElastic(2 * t, a, p)
	end

	return 0.5 * (1 + math.EaseOutElastic(2 * t - 1, a, p))
end

function math.EaseOutBounce(t)
	if t < (1 / 2.75) then
		return 7.5625 * t * t
	elseif t < (2 / 2.75) then
		t = t - (1.5 / 2.75)
		return (7.5625 * t) * t + 0.75
	elseif t < (2.5 / 2.75) then
		t = t - (2.25 / 2.75)
		return (7.5625 * t) * t + 0.9375
	else
		t = t - (2.625 / 2.75)
		return (7.5625 * t) * t + 0.984375
	end
end

function math.EaseInBounce(t)
	return 1 - math.EaseOutBounce(1 - t)
end

function math.EaseInOutBounce(t)
	if t < 0.5 then
		return 0.5 * math.EaseInBounce(2 * t)
	end

	return 0.5 * (1 + math.EaseOutBounce(2 * t - 1))
end

function math.EaseOutBack(t, s)
	s = s or 1.70158

	t = 1 - t

	return 1 - t * t * ((s + 1) * t - s)
end

function math.LerpNoClamp(t, a, b)
	return a + t * (b - a)
end

function math.RayIntersectSphere(startPos, rayDir, spherePos, sphereRadius)
	local dst = startPos - spherePos
	local b = dst:Dot(rayDir)
	local c = dst:Dot(dst) - (sphereRadius * sphereRadius)
	local d = b * b - c

	if d > 0 then
		return true, -b - math.sqrt(d)
	end

	return false
end
