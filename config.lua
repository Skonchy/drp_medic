DRPMedicJob={}

DRPMedicJob.LockerRooms = {}
DRPMedicJob.SignOnAndOff = {}
DRPMedicJob.Garages = {}


DRPMedicJob.SignOnAndOff = {
    {x = 299.85, y = -578.78, z = 43.26}
}

DRPMedicJob.Garages = {}

DRPMedicJob.Garages["Emergency Medical Technician"] = {
    Vehicles = {
        {label = "2015 Ford F-450 Ambulance", model = "ambulance", extras = {}, livery = 0, allowedRanks = 1, division = false},
        {label = "Alexis Custom Top Mount Fire Truck", model = "firetruk", extras = {}, livery = 0, allowedRanks = 3, division = false},
    },
    GameStuff = {
        BlipData = {label = "EMS Garage", sprite = 198, color = 77, scale = 1.0},
        MarkerData = {label = "~b~[E]~w~ EMS/Fire Garage", markerType = 1, color = {255, 0, 0}, scale = 1.0},
        Locations = {
            {
                x = 294.71,
                y = -600.91,
                z = 43.3,
                spawnpoints = {
                    {x = 288.75, y = -611.32, z = 43.38, h = 43.38}
                }
            }
        }
    }
}