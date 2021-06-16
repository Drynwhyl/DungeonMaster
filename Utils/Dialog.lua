WM('Dialog', function(import, export, exportDefault)
    local Utils = import 'Utils'

    local Dialog = {}

    ---@param buttonDataList table
    function Dialog.create(buttonDataList)
        local dialog = DialogCreate()
        local callbacks = {}
        for _, buttonData in ipairs(buttonDataList) do
            callbacks[DialogAddButton(dialog, buttonData.text, buttonData.hotkey)] = buttonData.callback
        end
        local trigger = CreateTrigger()
        TriggerRegisterDialogEvent(trigger, dialog)
        TriggerAddAction(trigger, Utils.pcall(function()
            local callback = callbacks[GetClickedButton()]
            if callback ~= nil then
                callback()
            end
        end))
        return dialog
    end

    exportDefault(Dialog)
end)
