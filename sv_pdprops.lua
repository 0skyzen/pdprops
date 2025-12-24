exports('useItem', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        if item.name == 'pd_cone' or item.name == 'pd_spikestrip' or item.name == 'pd_barrier' then
            TriggerClientEvent('sk_pdprops:useItem', inventory.id, item.name)
            return false 
        end
    elseif event == 'usedItem' then
        return false
    end
    return false
end)

RegisterNetEvent('sk_pdprops:removeItem', function(itemName)
    local src = source
    exports.ox_inventory:RemoveItem(src, itemName, 1)
end)

RegisterNetEvent('sk_pdprops:giveItem', function(itemName)
    local src = source
    exports.ox_inventory:AddItem(src, itemName, 1)
end)

