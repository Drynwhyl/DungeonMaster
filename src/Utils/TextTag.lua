local TextTag = {}

-- ==============================================================================
--   TEXT TAG - Floating text system by Cohadar - v5.0
-- ==============================================================================
--
--   PURPOUSE:
--        * Displaying floating text - the easy way
--        * Has a set of useful and commonly needed texttag functions
--
--   CREDITS:
--        * DioD - for extracting proper color, fadepoint and lifespan parameters
--          for default warcraft texttags (from miscdata.txt)
--
--   HOW TO IMPORT:
--        * Just create a trigger named TextTag
--          convert it to text and replace the whole trigger text with this one
-- ==============================================================================
--  for custom centered texttags
MEAN_CHAR_WIDTH = 5.5    ---@type number
MAX_TEXT_SHIFT = 200.0    ---@type number
DEFAULT_HEIGHT = 16.0    ---@type number
--  for default texttags
SIGN_SHIFT = 16.0    ---@type number
FONT_SIZE = 0.024    ---@type number
MISS = "miss"    ---@type string
-- ===========================================================================
--    Custom centered texttag on (x,y) position
--    color is in default wc3 format, for example "|cFFFFCC00"
-- ===========================================================================

---@param x number
---@param y number
---@param text string
---@param color string
---@return void
function TextTag.XY(x, y, text, red, green, blue, show)
    local tt = CreateTextTag()
    local shift = RMinBJ(StringLength(text) * MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
    SetTextTagText(tt, text, FONT_SIZE)
    SetTextTagColor(tt, red, green, blue, 255)
    SetTextTagPos(tt, x - shift, y, DEFAULT_HEIGHT)
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, show ~= false)
    SetTextTagFadepoint(tt, 2.5)
    SetTextTagLifespan(tt, 4.0)
    SetTextTagPermanent(tt, false)
    tt = nil
end
-- ===========================================================================
--    Custom centered texttag above unit
-- ===========================================================================

---@param whichUnit unit
---@param text string
---@param color string
---@return void
function TextTag.Unit(whichUnit, text, red, green, blue, show)
    local tt = CreateTextTag()
    local shift = RMinBJ(StringLength(text) * MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
    SetTextTagText(tt, text, FONT_SIZE)
    SetTextTagColor(tt, red, green, blue, 255)
    SetTextTagPos(tt, GetUnitX(whichUnit) - shift, GetUnitY(whichUnit), DEFAULT_HEIGHT)
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, show ~= false)
    SetTextTagFadepoint(tt, 2.5)
    SetTextTagLifespan(tt, 4.0)
    SetTextTagPermanent(tt, false)
    tt = nil
end
-- ===========================================================================
--   Standard wc3 gold bounty texttag, displayed only to killing player
-- ===========================================================================

---@param whichUnit unit
---@param bounty number
---@param killer player
---@return void
function TextTag.GoldBounty(whichUnit, bounty, show)
    local tt = CreateTextTag()
    local text = "+" .. I2S(bounty)
    SetTextTagText(tt, text, FONT_SIZE)
    SetTextTagPos(tt, GetUnitX(whichUnit) - SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 220, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.03)
    SetTextTagVisibility(tt, show ~= false)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 3.0)
    SetTextTagPermanent(tt, false)
    text = nil
    tt = nil
end
-- ==============================================================================

---@param whichUnit unit
---@param bounty number
---@param killer player
---@return void
function TextTag.LumberBounty(whichUnit, bounty, killer)
    local tt = CreateTextTag()
    local text = "+" .. I2S(bounty)
    SetTextTagText(tt, text, FONT_SIZE)
    SetTextTagPos(tt, GetUnitX(whichUnit) - SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 0, 200, 80, 255)
    SetTextTagVelocity(tt, 0.0, 0.03)
    SetTextTagVisibility(tt, GetLocalPlayer() == killer)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 3.0)
    SetTextTagPermanent(tt, false)
    text = nil
    tt = nil
end
-- ===========================================================================

---@param whichUnit unit
---@param dmg number
---@return void
function TextTag.ManaBurn(whichUnit, dmg)
    local tt = CreateTextTag()
    local text = "-" .. I2S(dmg)
    SetTextTagText(tt, text, FONT_SIZE)
    SetTextTagPos(tt, GetUnitX(whichUnit) - SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 82, 82, 255, 255)
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 5.0)
    SetTextTagPermanent(tt, false)
    text = nil
    tt = nil
end
-- ===========================================================================

---@param whichUnit unit
---@return void
function TextTag.Miss(whichUnit)
    local tt = CreateTextTag()
    SetTextTagText(tt, MISS, FONT_SIZE)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 0, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.03)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 1.0)
    SetTextTagLifespan(tt, 3.0)
    SetTextTagPermanent(tt, false)
    tt = nil
end
-- ===========================================================================

---@param whichUnit unit
---@param dmg number
---@return void
function TextTag.CriticalStrike(whichUnit, dmg)
    local tt = CreateTextTag()
    local text = I2S(dmg) .. "!"
    SetTextTagText(tt, text, FONT_SIZE)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 0, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 5.0)
    SetTextTagPermanent(tt, false)
    text = nil
    tt = nil
end
-- ===========================================================================

---@param whichUnit unit
---@param dmg number
---@param initialDamage boolean
---@return void
function TextTag.ShadowStrike(whichUnit, dmg, initialDamage)
    local tt = CreateTextTag()
    local text = I2S(dmg)
    if initialDamage then
        text = text .. "!"
    end
    SetTextTagText(tt, text, FONT_SIZE)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 160, 255, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 5.0)
    SetTextTagPermanent(tt, false)
    text = nil
    tt = nil
end

return TextTag