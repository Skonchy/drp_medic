DRPMedicJob={}

DRPMedicJob.LockerRooms = {}
DRPMedicJob.SignOnAndOff = {}
DRPMedicJob.Garages = {}


DRPMedicJob.SignOnAndOff = {
    {x = 299.34, y = -1447.52, z = 29.9}
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
                x = 307.05,
                y = -1434.57,
                z = 29.9,
                spawnpoints = {
                    {x = 296.54, y = -1430.83, z = 29.8, h = 42.71}
                }
            }
        }
    }
}