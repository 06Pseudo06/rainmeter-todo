isSelectedMark = 'x'
divider = '|'

COLUMN_INDEX_TASK_NAME = 1
COLUMN_INDEX_CHECKBOX = 2
COLUMN_INDEX_RECURRING = 3
COLUMN_INDEX_IMPORTANT = 4

function Initialize()
	sDynamicMeterFile = SKIN:ReplaceVariables(SELF:GetOption('DynamicMeterFile', '#@#DynamicMeters.inc'))
	sTaskListFile = SKIN:ReplaceVariables(SELF:GetOption('TaskListFile', '#CURRENTPATH#tasks.txt'))
	sTrashListFile = SKIN:ReplaceVariables(SELF:GetOption('TrashTaskListFile', '#CURRENTPATH#trash.txt'))
	SHOW_RECURRING = SELF:GetNumberOption('SHOW_RECURRING', 1)
	SHOW_IMPORTANT = SELF:GetNumberOption('SHOW_IMPORTANT', 1)
	TRASH_LIMIT = SELF:GetNumberOption('TRASH_LIMIT', 10)
	SKIN_WIDTH = SELF:GetNumberOption('SkinWidth', 340)
	COLLAPSED = SELF:GetNumberOption('COLLAPSED', 0)

	-- Theme colors
	COLOR_BG = SKIN:ReplaceVariables(SELF:GetOption('BG_COLOR', '252,250,246,245'))
	COLOR_BORDER = SKIN:ReplaceVariables(SELF:GetOption('BORDER_COLOR', '232,226,218,255'))
	COLOR_TEXT_PRIMARY = SKIN:ReplaceVariables(SELF:GetOption('TEXT_PRIMARY', '48,42,40,240'))
	COLOR_TEXT_MUTED = SKIN:ReplaceVariables(SELF:GetOption('TEXT_MUTED', '160,152,145,210'))
	COLOR_ACCENT = SKIN:ReplaceVariables(SELF:GetOption('ACCENT_COLOR', '225,120,135,255'))
	COLOR_CHECKBOX = SKIN:ReplaceVariables(SELF:GetOption('CHECKBOX_COLOR', '190,180,172,255'))
	COLOR_IMPORTANT = SKIN:ReplaceVariables(SELF:GetOption('IMPORTANT_COLOR', '235,160,70,255'))
	COLOR_RECURRING = SKIN:ReplaceVariables(SELF:GetOption('RECURRING_COLOR', '135,165,145,255'))
	COLOR_ICON_INACTIVE = SKIN:ReplaceVariables(SELF:GetOption('ICON_INACTIVE', '218,212,204,140'))
	COLOR_ICON_ACTION = SKIN:ReplaceVariables(SELF:GetOption('ICON_ACTION', '175,165,158,230'))
	COLOR_PROGRESS_BG = SKIN:ReplaceVariables(SELF:GetOption('PROGRESS_BAR_BG', '238,233,226,255'))
	COLOR_PROGRESS_FILL = SKIN:ReplaceVariables(SELF:GetOption('PROGRESS_BAR_FILL', '225,120,135,255'))

	FONT_FACE = SKIN:ReplaceVariables(SELF:GetOption('FONT_FACE', 'Inter'))
	FONT_SIZE = SELF:GetNumberOption('FONT_SIZE', 11)
	BUTTON_SIZE = SELF:GetNumberOption('BUTTON_SIZE', 13)
end

function GetTasks()
	local taskList = {}
	local hFile = io.open(sTaskListFile, 'r')
	if hFile then
		for line in hFile:lines() do
			if line and line ~= '' then
				local split = SplitText(line)
				while #split < 4 do
					split[#split + 1] = ''
				end
				taskList[#taskList + 1] = split
			end
		end
		hFile:close()
	end
	return taskList
end

function GetTrash()
	local trashTaskList = {}
	local hFile = io.open(sTrashListFile, 'r')
	if hFile then
		for line in hFile:lines() do
			if line and line ~= '' then
				trashTaskList[#trashTaskList + 1] = line
			end
		end
		hFile:close()
	end
	return trashTaskList
end

function SetCollapsed(val)
	COLLAPSED = tonumber(val) or 0
	SKIN:Bang('!WriteKeyValue', 'Variables', 'COLLAPSED', tostring(COLLAPSED))
	Update()
	SKIN:Bang('!Refresh')
end

function ToggleCollapsed()
	if COLLAPSED == 1 then
		SetCollapsed(0)
	else
		SetCollapsed(1)
	end
end

function Update()
	dynamicOutput = {}
	tasks = GetTasks()

	-- Include Material Icons definitions at the top
	dynamicOutput[#dynamicOutput + 1] = '@IncludeMUI=#@#MUI.inc'

	if COLLAPSED == 1 then
		-- Compact / Collapsed Mode: tiny cute heart card
		dynamicOutput[#dynamicOutput + 1] = '[MeterCardBackground]'
		dynamicOutput[#dynamicOutput + 1] = 'Meter=Shape'
		dynamicOutput[#dynamicOutput + 1] = 'Shape=Rectangle 0,0,42,42,12,12 | Fill Color ' .. COLOR_BG .. ' | StrokeWidth 1 | Stroke Color ' .. COLOR_BORDER
		dynamicOutput[#dynamicOutput + 1] = 'DynamicVariables=1'

		dynamicOutput[#dynamicOutput + 1] = '[MeterCollapsedHeart]'
		dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
		dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-heart#'
		dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
		dynamicOutput[#dynamicOutput + 1] = 'FontSize=15'
		dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ACCENT
		dynamicOutput[#dynamicOutput + 1] = 'StringAlign=CenterCenter'
		dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
		dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
		dynamicOutput[#dynamicOutput + 1] = 'X=21'
		dynamicOutput[#dynamicOutput + 1] = 'Y=21'
		dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Click to expand To-Do widget'
		dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "SetCollapsed(0)"]'

		local File = io.open(sDynamicMeterFile, 'w')
		if File then
			File:write(table.concat(dynamicOutput, '\n'))
			File:close()
		end
		return true
	end

	-- Expanded Mode
	local startIndex = 1
	if #tasks > 0 and string.lower(tasks[1][COLUMN_INDEX_TASK_NAME]) == 'task' then
		startIndex = 2
	end

	local totalCount = 0
	local completedCount = 0
	for i = startIndex, #tasks do
		totalCount = totalCount + 1
		if tasks[i][COLUMN_INDEX_CHECKBOX] == isSelectedMark then
			completedCount = completedCount + 1
		end
	end

	local percent = 0
	if totalCount > 0 then
		percent = math.floor((completedCount / totalCount) * 100)
	end

	-- Card Height Calculation:
	local taskHeight = totalCount > 0 and (totalCount * 28) or 30
	local calculatedHeight = 75 + taskHeight + 37 + 42 + 18

	-- Card Background
	dynamicOutput[#dynamicOutput + 1] = '[MeterCardBackground]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=Shape'
	dynamicOutput[#dynamicOutput + 1] = 'Shape=Rectangle 0,0,' .. SKIN_WIDTH .. ',' .. calculatedHeight .. ',14,14 | Fill Color ' .. COLOR_BG .. ' | StrokeWidth 1 | Stroke Color ' .. COLOR_BORDER
	dynamicOutput[#dynamicOutput + 1] = 'DynamicVariables=1'

	-- Header: Heart + TODAY + Collapse button
	dynamicOutput[#dynamicOutput + 1] = '[MeterHeaderHeart]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-heart#'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=13'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ACCENT
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=20'
	dynamicOutput[#dynamicOutput + 1] = 'Y=16'
	dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Click to collapse'
	dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "SetCollapsed(1)"]'

	dynamicOutput[#dynamicOutput + 1] = '[MeterHeaderTitle]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'Text=TODAY'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=' .. FONT_FACE
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=12'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_TEXT_PRIMARY
	dynamicOutput[#dynamicOutput + 1] = 'StringStyle=Bold'
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=6R'
	dynamicOutput[#dynamicOutput + 1] = 'Y=1r'
	dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Click to collapse'
	dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "SetCollapsed(1)"]'

	dynamicOutput[#dynamicOutput + 1] = '[MeterCollapseButton]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-collapse#'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=12'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ICON_ACTION
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=(' .. SKIN_WIDTH .. ' - 34)'
	dynamicOutput[#dynamicOutput + 1] = 'Y=16'
	dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Collapse widget'
	dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "SetCollapsed(1)"]'

	-- Subtitle: Current Date
	dynamicOutput[#dynamicOutput + 1] = '[MeterHeaderDate]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'MeasureName=MeasureDate'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=' .. FONT_FACE
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=9'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_TEXT_MUTED
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=20'
	dynamicOutput[#dynamicOutput + 1] = 'Y=20R'

	-- Divider under header
	dynamicOutput[#dynamicOutput + 1] = '[MeterHeaderDivider]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=Shape'
	dynamicOutput[#dynamicOutput + 1] = 'Shape=Line 0,0,(' .. SKIN_WIDTH .. ' - 40),0 | StrokeWidth 1 | Stroke Color ' .. COLOR_BORDER
	dynamicOutput[#dynamicOutput + 1] = 'X=20'
	dynamicOutput[#dynamicOutput + 1] = 'Y=8R'

	-- Task meters
	local actionIconsWidth = 96
	local taskTextWidth = SKIN_WIDTH - 40 - 24 - actionIconsWidth - 8

	if totalCount == 0 then
		dynamicOutput[#dynamicOutput + 1] = '[MeterEmptyTasks]'
		dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
		dynamicOutput[#dynamicOutput + 1] = 'Text=No tasks for today'
		dynamicOutput[#dynamicOutput + 1] = 'FontFace=' .. FONT_FACE
		dynamicOutput[#dynamicOutput + 1] = 'FontSize=10'
		dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_TEXT_MUTED
		dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
		dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
		dynamicOutput[#dynamicOutput + 1] = 'X=20'
		dynamicOutput[#dynamicOutput + 1] = 'Y=12R'
	else
		for i = startIndex, #tasks do
			local isCompleted = (tasks[i][COLUMN_INDEX_CHECKBOX] == isSelectedMark)
			local isRecurring = (tasks[i][COLUMN_INDEX_RECURRING] == isSelectedMark)
			local isImportant = (tasks[i][COLUMN_INDEX_IMPORTANT] == isSelectedMark)
			local prevIndex = i - 1
			local nextIndex = i + 1
			local canMoveUp = (i > startIndex)
			local canMoveDown = (i < #tasks)

			-- Checkbox (Directly sets #mui-checked# or #mui-check#)
			dynamicOutput[#dynamicOutput + 1] = '[MeterTaskIcon' .. i .. ']'
			dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
			dynamicOutput[#dynamicOutput + 1] = 'Text=' .. (isCompleted and '#mui-checked#' or '#mui-check#')
			dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
			dynamicOutput[#dynamicOutput + 1] = 'FontSize=13'
			dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. (isCompleted and COLOR_ACCENT or COLOR_CHECKBOX)
			dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
			dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
			dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
			dynamicOutput[#dynamicOutput + 1] = 'X=20'
			dynamicOutput[#dynamicOutput + 1] = (i == startIndex) and 'Y=10R' or 'Y=6R'
			dynamicOutput[#dynamicOutput + 1] = 'H=22'
			dynamicOutput[#dynamicOutput + 1] = 'W=22'
			dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Toggle completion'
			dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "Toggle(' .. i .. ',2)"]'

			-- Task Name Text
			dynamicOutput[#dynamicOutput + 1] = '[MeterRepeatingTask' .. i .. ']'
			dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
			dynamicOutput[#dynamicOutput + 1] = 'Text=' .. tasks[i][COLUMN_INDEX_TASK_NAME]
			dynamicOutput[#dynamicOutput + 1] = 'FontFace=' .. FONT_FACE
			dynamicOutput[#dynamicOutput + 1] = 'FontSize=' .. FONT_SIZE
			dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. (isCompleted and COLOR_TEXT_MUTED or COLOR_TEXT_PRIMARY)
			if isCompleted then
				dynamicOutput[#dynamicOutput + 1] = 'InlineSetting=Strikethrough'
			end
			dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
			dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
			dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
			dynamicOutput[#dynamicOutput + 1] = 'X=4R'
			dynamicOutput[#dynamicOutput + 1] = 'Y=r'
			dynamicOutput[#dynamicOutput + 1] = 'H=22'
			dynamicOutput[#dynamicOutput + 1] = 'W=' .. taskTextWidth
			dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Toggle completion'
			dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "Toggle(' .. i .. ',2)"]'

			-- Important Icon
			if SHOW_IMPORTANT == 1 then
				dynamicOutput[#dynamicOutput + 1] = '[MeterImportantIcon' .. i .. ']'
				dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
				dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-important#'
				dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
				dynamicOutput[#dynamicOutput + 1] = 'FontSize=11'
				dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. (isImportant and COLOR_IMPORTANT or COLOR_ICON_INACTIVE)
				dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
				dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
				dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
				dynamicOutput[#dynamicOutput + 1] = 'X=4R'
				dynamicOutput[#dynamicOutput + 1] = 'Y=r'
				dynamicOutput[#dynamicOutput + 1] = 'H=22'
				dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Toggle important'
				dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "Toggle(' .. i .. ', 4)"]'
			end

			-- Recurring Icon
			if SHOW_RECURRING == 1 then
				dynamicOutput[#dynamicOutput + 1] = '[MeterRecurringIcon' .. i .. ']'
				dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
				dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-repeat#'
				dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
				dynamicOutput[#dynamicOutput + 1] = 'FontSize=11'
				dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. (isRecurring and COLOR_RECURRING or COLOR_ICON_INACTIVE)
				dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
				dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
				dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
				dynamicOutput[#dynamicOutput + 1] = 'X=3R'
				dynamicOutput[#dynamicOutput + 1] = 'Y=r'
				dynamicOutput[#dynamicOutput + 1] = 'H=22'
				dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Toggle recurring'
				dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "Toggle(' .. i .. ', 3)"]'
			end

			-- Move Up Icon
			dynamicOutput[#dynamicOutput + 1] = '[MeterTaskUpIcon' .. i .. ']'
			dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
			dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-up#'
			dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
			dynamicOutput[#dynamicOutput + 1] = 'FontSize=11'
			dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. (canMoveUp and COLOR_ICON_ACTION or '0,0,0,0')
			dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
			dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
			dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
			dynamicOutput[#dynamicOutput + 1] = 'X=3R'
			dynamicOutput[#dynamicOutput + 1] = 'Y=r'
			dynamicOutput[#dynamicOutput + 1] = 'H=22'
			if canMoveUp then
				dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Move task up'
				dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "ChangeOrder(' .. i .. ',' .. prevIndex .. ')"]'
			end

			-- Move Down Icon
			dynamicOutput[#dynamicOutput + 1] = '[MeterTaskDownIcon' .. i .. ']'
			dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
			dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-down#'
			dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
			dynamicOutput[#dynamicOutput + 1] = 'FontSize=11'
			dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. (canMoveDown and COLOR_ICON_ACTION or '0,0,0,0')
			dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
			dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
			dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
			dynamicOutput[#dynamicOutput + 1] = 'X=2R'
			dynamicOutput[#dynamicOutput + 1] = 'Y=r'
			dynamicOutput[#dynamicOutput + 1] = 'H=22'
			if canMoveDown then
				dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Move task down'
				dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "ChangeOrder(' .. i .. ',' .. nextIndex .. ')"]'
			end

			-- Delete Icon
			dynamicOutput[#dynamicOutput + 1] = '[MeterTaskDeleteIcon' .. i .. ']'
			dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
			dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-to-trash#'
			dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
			dynamicOutput[#dynamicOutput + 1] = 'FontSize=11'
			dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ICON_ACTION
			dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
			dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
			dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
			dynamicOutput[#dynamicOutput + 1] = 'X=3R'
			dynamicOutput[#dynamicOutput + 1] = 'Y=r'
			dynamicOutput[#dynamicOutput + 1] = 'H=22'
			dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Delete task'
			dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "RemoveTask(' .. i .. ')"]'
		end
	end

	-- Footer Divider
	dynamicOutput[#dynamicOutput + 1] = '[MeterFooterDivider]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=Shape'
	dynamicOutput[#dynamicOutput + 1] = 'Shape=Line 0,0,(' .. SKIN_WIDTH .. ' - 40),0 | StrokeWidth 1 | Stroke Color ' .. COLOR_BORDER
	dynamicOutput[#dynamicOutput + 1] = 'X=20'
	dynamicOutput[#dynamicOutput + 1] = 'Y=10R'

	-- Add Task Button (+ New task)
	dynamicOutput[#dynamicOutput + 1] = '[MeterAddTasks]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'Text=+ New task'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=' .. FONT_FACE
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=10'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ACCENT
	dynamicOutput[#dynamicOutput + 1] = 'StringStyle=Bold'
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=20'
	dynamicOutput[#dynamicOutput + 1] = 'Y=8R'
	dynamicOutput[#dynamicOutput + 1] = 'H=20'
	dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Click to add a new task'
	dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure MeasureInput "ExecuteBatch 1"]'

	-- Refresh button (bottom right)
	dynamicOutput[#dynamicOutput + 1] = '[MeterRefreshTasks]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-refresh#'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=12'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ICON_ACTION
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=(' .. SKIN_WIDTH .. ' - 50)'
	dynamicOutput[#dynamicOutput + 1] = 'Y=r'
	dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Refresh widget'
	dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!Refresh]'

	-- Undo button (if trash has items)
	local trashTasks = GetTrash()
	if #trashTasks > 0 then
		dynamicOutput[#dynamicOutput + 1] = '[MeterUndoTasks]'
		dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
		dynamicOutput[#dynamicOutput + 1] = 'Text=#mui-from-trash#'
		dynamicOutput[#dynamicOutput + 1] = 'FontFace=Material Icons'
		dynamicOutput[#dynamicOutput + 1] = 'FontSize=12'
		dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ICON_ACTION
		dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
		dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
		dynamicOutput[#dynamicOutput + 1] = 'ClipString=1'
		dynamicOutput[#dynamicOutput + 1] = 'X=6R'
		dynamicOutput[#dynamicOutput + 1] = 'Y=r'
		dynamicOutput[#dynamicOutput + 1] = 'ToolTipText=Undo last deleted task'
		dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "UndoDeletedTask()"]'
	end

	-- Progress Section
	dynamicOutput[#dynamicOutput + 1] = '[MeterProgressText]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'Text=' .. completedCount .. ' / ' .. totalCount .. ' completed'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=' .. FONT_FACE
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=9'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_TEXT_MUTED
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=20'
	dynamicOutput[#dynamicOutput + 1] = 'Y=12R'

	dynamicOutput[#dynamicOutput + 1] = '[MeterProgressPercent]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=String'
	dynamicOutput[#dynamicOutput + 1] = 'Text=' .. percent .. '%'
	dynamicOutput[#dynamicOutput + 1] = 'FontFace=' .. FONT_FACE
	dynamicOutput[#dynamicOutput + 1] = 'FontSize=9'
	dynamicOutput[#dynamicOutput + 1] = 'FontColor=' .. COLOR_ACCENT
	dynamicOutput[#dynamicOutput + 1] = 'StringStyle=Bold'
	dynamicOutput[#dynamicOutput + 1] = 'StringAlign=Right'
	dynamicOutput[#dynamicOutput + 1] = 'SolidColor=0,0,0,1'
	dynamicOutput[#dynamicOutput + 1] = 'AntiAlias=1'
	dynamicOutput[#dynamicOutput + 1] = 'X=(' .. SKIN_WIDTH .. ' - 20)'
	dynamicOutput[#dynamicOutput + 1] = 'Y=r'

	-- Progress Bar (Track & Fill)
	local barWidth = SKIN_WIDTH - 40
	local fillWidth = math.floor((barWidth * percent) / 100)
	if percent > 0 and fillWidth < 6 then
		fillWidth = 6
	end

	dynamicOutput[#dynamicOutput + 1] = '[MeterProgressBarBg]'
	dynamicOutput[#dynamicOutput + 1] = 'Meter=Shape'
	dynamicOutput[#dynamicOutput + 1] = 'Shape=Rectangle 0,0,' .. barWidth .. ',6,3 | Fill Color ' .. COLOR_PROGRESS_BG .. ' | StrokeWidth 0'
	dynamicOutput[#dynamicOutput + 1] = 'X=20'
	dynamicOutput[#dynamicOutput + 1] = 'Y=8R'

	if fillWidth > 0 then
		dynamicOutput[#dynamicOutput + 1] = '[MeterProgressBarFill]'
		dynamicOutput[#dynamicOutput + 1] = 'Meter=Shape'
		dynamicOutput[#dynamicOutput + 1] = 'Shape=Rectangle 0,0,' .. fillWidth .. ',6,3 | Fill Color ' .. COLOR_PROGRESS_FILL .. ' | StrokeWidth 0'
		dynamicOutput[#dynamicOutput + 1] = 'X=20'
		dynamicOutput[#dynamicOutput + 1] = 'Y=r'
	end

	-- Write dynamic meters file
	local File = io.open(sDynamicMeterFile, 'w')
	if not File then
		print('Update: unable to open file at ' .. sDynamicMeterFile)
		return false
	end

	File:write(table.concat(dynamicOutput, '\n'))
	File:close()
	return true
end

function Toggle(lineNumber, columnIndex)
	lineNumber = tonumber(lineNumber)
	columnIndex = tonumber(columnIndex)
	if not lineNumber or not columnIndex then return false end

	tasks = GetTasks()
	local content = {}

	for i = 1, #tasks do
		if i == lineNumber then
			if tasks[i][columnIndex] == isSelectedMark then
				tasks[i][columnIndex] = ''
			else
				tasks[i][columnIndex] = isSelectedMark
			end
		end
		content[#content + 1] = table.concat(tasks[i], divider)
	end

	local hFile = io.open(sTaskListFile, 'w+')
	if hFile then
		for i = 1, #content do
			hFile:write(string.format('%s\n', content[i]))
		end
		hFile:close()
	end

	Update()
	SKIN:Bang('!Refresh')
	return true
end

function ChangeOrder(currentLine, nextLine)
	currentLine = tonumber(currentLine)
	nextLine = tonumber(nextLine)
	if not currentLine or not nextLine then return false end

	tasks = GetTasks()
	local startIndex = 1
	if #tasks > 0 and string.lower(tasks[1][COLUMN_INDEX_TASK_NAME]) == 'task' then
		startIndex = 2
	end

	if nextLine < startIndex or nextLine > #tasks or currentLine < startIndex or currentLine > #tasks then
		return false
	end

	local temp = tasks[currentLine]
	tasks[currentLine] = tasks[nextLine]
	tasks[nextLine] = temp

	local content = {}
	for i = 1, #tasks do
		content[#content + 1] = table.concat(tasks[i], divider)
	end

	local hFile = io.open(sTaskListFile, 'w+')
	if hFile then
		for i = 1, #content do
			hFile:write(string.format('%s\n', content[i]))
		end
		hFile:close()
	end

	Update()
	SKIN:Bang('!Refresh')
	return true
end

function AddTask(newline)
	if not newline or newline == '' then return false end
	-- Strip surrounding quotes, backticks, or whitespace
	newline = string.gsub(newline, '^[\'"`%s]*(.-)[\'"`%s]*$', '%1')
	if newline == '' then return false end

	local wholeFile = ''
	local hFile = io.open(sTaskListFile, 'r')
	if hFile then
		wholeFile = hFile:read('*a')
		hFile:close()
	end

	if wholeFile ~= '' and not string.match(wholeFile, '\n$') then
		wholeFile = wholeFile .. '\n'
	end

	hFile = io.open(sTaskListFile, 'w')
	if hFile then
		hFile:write(wholeFile)
		hFile:write(newline .. '|||\n')
		hFile:close()
	end

	Update()
	SKIN:Bang('!Refresh')
	return true
end

function AddToTrash(newline)
	if not newline or newline == '' then return false end
	local wholeFile = ''
	local hFile = io.open(sTrashListFile, 'r')
	if hFile then
		wholeFile = hFile:read('*a')
		hFile:close()
	end

	if wholeFile ~= '' and not string.match(wholeFile, '\n$') then
		wholeFile = wholeFile .. '\n'
	end

	hFile = io.open(sTrashListFile, 'w')
	if hFile then
		hFile:write(wholeFile)
		hFile:write(newline .. '\n')
		hFile:close()
	end
	return true
end

function RemoveTask(starting_line, isPermanentDelete)
	starting_line = tonumber(starting_line)
	isPermanentDelete = tonumber(isPermanentDelete)
	if not starting_line then return false end

	local targetFile = sTaskListFile
	tasks = GetTasks()

	if isPermanentDelete == 1 then
		targetFile = sTrashListFile
	end

	local content = {}
	local hFile = io.open(targetFile, 'r')
	if hFile then
		local i = 1
		for line in hFile:lines() do
			if i ~= starting_line then
				content[#content + 1] = line
			end
			i = i + 1
		end
		hFile:close()
	end

	hFile = io.open(targetFile, 'w+')
	if hFile then
		for i = 1, #content do
			hFile:write(string.format('%s\n', content[i]))
		end
		hFile:close()
	end

	if isPermanentDelete ~= 1 and tasks[starting_line] then
		AddToTrash(tasks[starting_line][1])
		local trashTasks = GetTrash()
		if #trashTasks > TRASH_LIMIT then
			RemoveTask(1, 1)
		end
	end

	Update()
	SKIN:Bang('!Refresh')
	return true
end

function UndoDeletedTask()
	local trashTasks = GetTrash()
	if #trashTasks > 0 then
		local lastItem = trashTasks[#trashTasks]
		RemoveTask(#trashTasks, 1)
		AddTask(lastItem)
	end
	return true
end

function SplitText(inputstr, sep)
	sep = sep or '%|'
	local t = {}
	for field, s in string.gmatch(inputstr, '([^' .. sep .. ']*)(' .. sep .. '?)') do
		table.insert(t, field)
		if s == '' then return t end
	end
	return t
end
