local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local modern_bar = {}

function modern_bar.setup(s, tasklist_buttons)
	-- Ukuran font custom (sesuaikan angka 12 atau 14 sesuai selera)
	-- Tambahkan baris ini di dalam fungsi modern_bar.setup(s, ...)

	-- Tentukan berapa pixel area monitor yang rusak (misal 30px)
	local dead_zone = 30

	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		height = 24,
		-- Ini kunci utamanya: Menambahkan margin atas sebesar area yang rusak
		margins = {
			top = dead_zone,
			left = 10, -- Opsional: agar lebih estetik (floating)
			right = 10,
		},
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, 8)
		end,
		bg = "#1a1b26",
	})
	local main_font = "Sans Bold 8"

	-- 1. Definisikan Tasklist: Hanya Icon (Font tidak berpengaruh di sini karena icon only)
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		layout = {
			spacing = 8,
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					{
						id = "clienticon",
						widget = wibox.widget.imagebox,
					},
					margins = 6,
					widget = wibox.container.margin,
				},
				id = "background_role", -- Ini kunci untuk status aktif
				widget = wibox.container.background,
			},
			-- Membuat bentuk "Pill" atau kotak tumpul untuk indikator aktif
			create_callback = function(self, c, index, objects)
				self:get_children_by_id("clienticon")[1].image = c.icon
				-- Tambahkan shape bulat pada background agar modern
				self:get_children_by_id("background_role")[1].shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, 6)
				end
			end,
			widget = wibox.container.margin,
		},
	})
	-- 2. Jam dengan font lebih besar
	local mytextclock = wibox.widget.textclock()
	mytextclock.font = main_font

	-- 3. Taglist (Workspace) dengan font lebih besar
	-- Kita override font taglist bawaan di sini
	s.mytaglist.font = main_font
	--title
	s.mytitlewidget = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.focused, -- Hanya ambil yang sedang fokus
		layout = { layout = wibox.layout.fixed.horizontal },
		widget_template = {
			{
				id = "text_role",
				widget = wibox.widget.textbox,
			},
			layout = wibox.container.margin,
			left = 10,
			right = 10,
		},
	})

	-- Susunan Wibar
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{ -- KIRI
			layout = wibox.layout.fixed.horizontal,
			s.mylaucher,
			s.mytitlewidget,
			s.mytitlewidget,
		},
		{ -- TENGAH
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
		},
		{ -- KANAN
			layout = wibox.layout.fixed.horizontal,
			spacing = 12,
			s.mytasklist,
			wibox.widget.systray(),
			mytextclock, -- Menggunakan jam yang sudah diperbesar font-nya
		},
	})
end

return modern_bar
