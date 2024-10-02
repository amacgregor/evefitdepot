defmodule Evefitdepot.EFTParserTest do
  use ExUnit.Case, async: true

  alias Evefitdepot.EFTParser

  describe "parse/1" do
    test "parses a fitting for a non-T3 ship without errors" do
      eft_text = """
      [Enforcer,L4 Enforcer Autocannon Shield]
      Gyrostabilizer II
      Gyrostabilizer II
      Gyrostabilizer II
      Tracking Enhancer II
      Damage Control II

      Pithum B-Type Medium Shield Booster
      Shield Boost Amplifier II
      Republic Fleet Medium Cap Battery
      Federation Navy 10MN Afterburner
      Multispectrum Shield Hardener II

      425mm AutoCannon II, Hail M
      425mm AutoCannon II, Hail M
      425mm AutoCannon II, Hail M
      425mm AutoCannon II, Hail M
      425mm AutoCannon II, Hail M
      Heavy Assault Missile Launcher II, Nova Rage Heavy Assault Missile
      Heavy Assault Missile Launcher II, Nova Rage Heavy Assault Missile

      Medium Capacitor Control Circuit II
      Medium Capacitor Control Circuit II

      Hornet II x5

      Barrage M x6000
      Hail M x6000
      Mjolnir Rage Heavy Assault Missile x1000
      Nova Rage Heavy Assault Missile x1000
      Republic Fleet EMP M x1000
      Republic Fleet Fusion M x2000
      """

      expected_result = %{
        "ship" => "Enforcer",
        "fitting_name" => "L4 Enforcer Autocannon Shield",
        "slots" => %{
          "low" => [
            %{"name" => "Gyrostabilizer II", "charge" => nil},
            %{"name" => "Gyrostabilizer II", "charge" => nil},
            %{"name" => "Gyrostabilizer II", "charge" => nil},
            %{"name" => "Tracking Enhancer II", "charge" => nil},
            %{"name" => "Damage Control II", "charge" => nil}
          ],
          "mid" => [
            %{"name" => "Pithum B-Type Medium Shield Booster", "charge" => nil},
            %{"name" => "Shield Boost Amplifier II", "charge" => nil},
            %{"name" => "Republic Fleet Medium Cap Battery", "charge" => nil},
            %{"name" => "Federation Navy 10MN Afterburner", "charge" => nil},
            %{"name" => "Multispectrum Shield Hardener II", "charge" => nil}
          ],
          "high" => [
            %{"name" => "425mm AutoCannon II", "charge" => "Hail M"},
            %{"name" => "425mm AutoCannon II", "charge" => "Hail M"},
            %{"name" => "425mm AutoCannon II", "charge" => "Hail M"},
            %{"name" => "425mm AutoCannon II", "charge" => "Hail M"},
            %{"name" => "425mm AutoCannon II", "charge" => "Hail M"},
            %{
              "name" => "Heavy Assault Missile Launcher II",
              "charge" => "Nova Rage Heavy Assault Missile"
            },
            %{
              "name" => "Heavy Assault Missile Launcher II",
              "charge" => "Nova Rage Heavy Assault Missile"
            }
          ],
          "rigs" => [
            %{"name" => "Medium Capacitor Control Circuit II", "charge" => nil},
            %{"name" => "Medium Capacitor Control Circuit II", "charge" => nil}
          ]
          # "subsystems" is not included for non-T3 ships
        },
        "drones" => [
          %{"name" => "Hornet II", "quantity" => 5}
        ],
        "cargo" => [
          %{"name" => "Barrage M", "quantity" => 6000},
          %{"name" => "Hail M", "quantity" => 6000},
          %{"name" => "Mjolnir Rage Heavy Assault Missile", "quantity" => 1000},
          %{"name" => "Nova Rage Heavy Assault Missile", "quantity" => 1000},
          %{"name" => "Republic Fleet EMP M", "quantity" => 1000},
          %{"name" => "Republic Fleet Fusion M", "quantity" => 2000}
        ]
      }

      assert EFTParser.parse(eft_text) == expected_result
    end

    test "parses a fitting for a T3 ship with subsystems" do
      eft_text = """
      [Tengu, Tengu Fit Example]
      Ballistic Control System II
      Ballistic Control System II
      Ballistic Control System II
      Ballistic Control System II

      10MN Afterburner II
      Adaptive Invulnerability Field II
      Large Shield Extender II
      Large Shield Extender II
      Shield Boost Amplifier II
      EM Ward Amplifier II

      Heavy Missile Launcher II, Scourge Fury Heavy Missile
      Heavy Missile Launcher II, Scourge Fury Heavy Missile
      Heavy Missile Launcher II, Scourge Fury Heavy Missile
      Heavy Missile Launcher II, Scourge Fury Heavy Missile
      Heavy Missile Launcher II, Scourge Fury Heavy Missile
      Heavy Missile Launcher II, Scourge Fury Heavy Missile

      Medium Warhead Rigor Catalyst II
      Medium Warhead Flare Catalyst II
      [Empty Rig slot]

      Tengu Defensive - Adaptive Shielding
      Tengu Electronics - Dissolution Sequencer
      Tengu Engineering - Capacitor Regeneration Matrix
      Tengu Offensive - Accelerated Ejection Bay
      Tengu Propulsion - Fuel Catalyst

      Warrior II x5

      Scourge Fury Heavy Missile x2000
      Nanite Repair Paste x100
      """

      expected_result = %{
        "ship" => "Tengu",
        "fitting_name" => "Tengu Fit Example",
        "slots" => %{
          "low" => [
            %{"name" => "Ballistic Control System II", "charge" => nil},
            %{"name" => "Ballistic Control System II", "charge" => nil},
            %{"name" => "Ballistic Control System II", "charge" => nil},
            %{"name" => "Ballistic Control System II", "charge" => nil}
          ],
          "mid" => [
            %{"name" => "10MN Afterburner II", "charge" => nil},
            %{"name" => "Adaptive Invulnerability Field II", "charge" => nil},
            %{"name" => "Large Shield Extender II", "charge" => nil},
            %{"name" => "Large Shield Extender II", "charge" => nil},
            %{"name" => "Shield Boost Amplifier II", "charge" => nil},
            %{"name" => "EM Ward Amplifier II", "charge" => nil}
          ],
          "high" => [
            %{"name" => "Heavy Missile Launcher II", "charge" => "Scourge Fury Heavy Missile"},
            %{"name" => "Heavy Missile Launcher II", "charge" => "Scourge Fury Heavy Missile"},
            %{"name" => "Heavy Missile Launcher II", "charge" => "Scourge Fury Heavy Missile"},
            %{"name" => "Heavy Missile Launcher II", "charge" => "Scourge Fury Heavy Missile"},
            %{"name" => "Heavy Missile Launcher II", "charge" => "Scourge Fury Heavy Missile"},
            %{"name" => "Heavy Missile Launcher II", "charge" => "Scourge Fury Heavy Missile"}
          ],
          "rigs" => [
            %{"name" => "Medium Warhead Rigor Catalyst II", "charge" => nil},
            %{"name" => "Medium Warhead Flare Catalyst II", "charge" => nil},
            %{"name" => "[Empty Rig slot]", "charge" => nil}
          ],
          "subsystems" => [
            %{"name" => "Tengu Defensive - Adaptive Shielding", "charge" => nil},
            %{"name" => "Tengu Electronics - Dissolution Sequencer", "charge" => nil},
            %{"name" => "Tengu Engineering - Capacitor Regeneration Matrix", "charge" => nil},
            %{"name" => "Tengu Offensive - Accelerated Ejection Bay", "charge" => nil},
            %{"name" => "Tengu Propulsion - Fuel Catalyst", "charge" => nil}
          ]
        },
        "drones" => [
          %{"name" => "Warrior II", "quantity" => 5}
        ],
        "cargo" => [
          %{"name" => "Scourge Fury Heavy Missile", "quantity" => 2000},
          %{"name" => "Nanite Repair Paste", "quantity" => 100}
        ]
      }

      assert EFTParser.parse(eft_text) == expected_result
    end

    test "parses a fitting with missing sections" do
      eft_text = """
      [Rifter, Basic Rifter Fit]
      200mm AutoCannon I
      200mm AutoCannon I
      200mm AutoCannon I

      1MN Afterburner I

      Small Armor Repairer I

      Warrior I x2
      """

      expected_result = %{
        "ship" => "Rifter",
        "fitting_name" => "Basic Rifter Fit",
        "slots" => %{
          "low" => [
            %{"name" => "200mm AutoCannon I", "charge" => nil},
            %{"name" => "200mm AutoCannon I", "charge" => nil},
            %{"name" => "200mm AutoCannon I", "charge" => nil}
          ],
          "mid" => [
            %{"name" => "1MN Afterburner I", "charge" => nil}
          ],
          "high" => [
            %{"name" => "Small Armor Repairer I", "charge" => nil}
          ],
          "rigs" => []
          # "subsystems" is not included
        },
        "drones" => [
          %{"name" => "Warrior I", "quantity" => 2}
        ],
        "cargo" => []
      }

      assert EFTParser.parse(eft_text) == expected_result
    end

    test "parses a fitting with modules having no charges" do
      eft_text = """
      [Vexor, Drone Boat]
      Damage Control II
      Drone Damage Amplifier II
      Drone Damage Amplifier II
      Drone Damage Amplifier II

      50MN Microwarpdrive II
      Large Shield Extender II
      Large Shield Extender II
      Adaptive Invulnerability Field II

      [Empty High slot]
      [Empty High slot]
      [Empty High slot]
      [Empty High slot]
      [Empty High slot]

      Medium Core Defense Field Extender I
      Medium Core Defense Field Extender I
      Medium Core Defense Field Extender I

      Hobgoblin II x5
      Hammerhead II x5
      Ogre II x2
      """

      expected_result = %{
        "ship" => "Vexor",
        "fitting_name" => "Drone Boat",
        "slots" => %{
          "low" => [
            %{"name" => "Damage Control II", "charge" => nil},
            %{"name" => "Drone Damage Amplifier II", "charge" => nil},
            %{"name" => "Drone Damage Amplifier II", "charge" => nil},
            %{"name" => "Drone Damage Amplifier II", "charge" => nil}
          ],
          "mid" => [
            %{"name" => "50MN Microwarpdrive II", "charge" => nil},
            %{"name" => "Large Shield Extender II", "charge" => nil},
            %{"name" => "Large Shield Extender II", "charge" => nil},
            %{"name" => "Adaptive Invulnerability Field II", "charge" => nil}
          ],
          "high" => [
            %{"name" => "[Empty High slot]", "charge" => nil},
            %{"name" => "[Empty High slot]", "charge" => nil},
            %{"name" => "[Empty High slot]", "charge" => nil},
            %{"name" => "[Empty High slot]", "charge" => nil},
            %{"name" => "[Empty High slot]", "charge" => nil}
          ],
          "rigs" => [
            %{"name" => "Medium Core Defense Field Extender I", "charge" => nil},
            %{"name" => "Medium Core Defense Field Extender I", "charge" => nil},
            %{"name" => "Medium Core Defense Field Extender I", "charge" => nil}
          ]
          # "subsystems" is not included
        },
        "drones" => [
          %{"name" => "Hobgoblin II", "quantity" => 5},
          %{"name" => "Hammerhead II", "quantity" => 5},
          %{"name" => "Ogre II", "quantity" => 2}
        ],
        "cargo" => []
      }

      assert EFTParser.parse(eft_text) == expected_result
    end

    test "parses a fitting with special characters in module names" do
      eft_text = """
      [Apocalypse Navy Issue, Laser Boat]
      Heat Sink II
      Heat Sink II
      Heat Sink II
      Tracking Enhancer II
      Tracking Enhancer II
      Damage Control II
      Reactor Control Unit II

      100MN Afterburner II
      Large Micro Jump Drive
      Tracking Computer II, Optimal Range Script

      Mega Pulse Laser II, Imperial Navy Multifrequency L
      Mega Pulse Laser II, Imperial Navy Multifrequency L
      Mega Pulse Laser II, Imperial Navy Multifrequency L
      Mega Pulse Laser II, Imperial Navy Multifrequency L
      Mega Pulse Laser II, Imperial Navy Multifrequency L
      Mega Pulse Laser II, Imperial Navy Multifrequency L
      Mega Pulse Laser II, Imperial Navy Multifrequency L
      Mega Pulse Laser II, Imperial Navy Multifrequency L

      Large Energy Locus Coordinator I
      Large Energy Locus Coordinator I
      Large Energy Locus Coordinator I

      Acolyte II x5

      Imperial Navy Multifrequency L x8
      """

      expected_result = %{
        "ship" => "Apocalypse Navy Issue",
        "fitting_name" => "Laser Boat",
        "slots" => %{
          "low" => [
            %{"name" => "Heat Sink II", "charge" => nil},
            %{"name" => "Heat Sink II", "charge" => nil},
            %{"name" => "Heat Sink II", "charge" => nil},
            %{"name" => "Tracking Enhancer II", "charge" => nil},
            %{"name" => "Tracking Enhancer II", "charge" => nil},
            %{"name" => "Damage Control II", "charge" => nil},
            %{"name" => "Reactor Control Unit II", "charge" => nil}
          ],
          "mid" => [
            %{"name" => "100MN Afterburner II", "charge" => nil},
            %{"name" => "Large Micro Jump Drive", "charge" => nil},
            %{"name" => "Tracking Computer II", "charge" => "Optimal Range Script"}
          ],
          "high" => [
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"},
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"},
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"},
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"},
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"},
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"},
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"},
            %{"name" => "Mega Pulse Laser II", "charge" => "Imperial Navy Multifrequency L"}
          ],
          "rigs" => [
            %{"name" => "Large Energy Locus Coordinator I", "charge" => nil},
            %{"name" => "Large Energy Locus Coordinator I", "charge" => nil},
            %{"name" => "Large Energy Locus Coordinator I", "charge" => nil}
          ]
          # "subsystems" is not included
        },
        "drones" => [
          %{"name" => "Acolyte II", "quantity" => 5}
        ],
        "cargo" => [
          %{"name" => "Imperial Navy Multifrequency L", "quantity" => 8}
        ]
      }

      assert EFTParser.parse(eft_text) == expected_result
    end

    test "parses fitting with no drones, but with cargo and boosters correctly" do
      eft_text = """
      [Tengu,Simulated Tengu Fitting]
      Ballistic Control System II
      Ballistic Control System II

      Republic Fleet Large Cap Battery
      Pith B-Type Shield Boost Amplifier
      Pith C-Type Large Shield Booster
      Federation Navy 10MN Afterburner
      Multispectrum Shield Hardener II
      Warp Scrambler II
      Stasis Webifier II

      Heavy Assault Missile Launcher II
      Heavy Assault Missile Launcher II
      Heavy Assault Missile Launcher II
      Heavy Assault Missile Launcher II
      Heavy Assault Missile Launcher II
      Heavy Assault Missile Launcher II
      Covert Ops Cloaking Device II
      Expanded Probe Launcher I

      Medium Ancillary Current Router I
      Medium EM Shield Reinforcer II
      Medium Capacitor Control Circuit II

      Tengu Core - Augmented Graviton Reactor
      Tengu Defensive - Covert Reconfiguration
      Tengu Offensive - Accelerated Ejection Bay
      Tengu Propulsion - Fuel Catalyst


      Agency 'Hardshell' TB5 Dose II
      Improved Blue Pill Booster


      Guristas Nova Heavy Assault Missile x1000
      Mjolnir Rage Heavy Assault Missile x1500
      Scourge Javelin Heavy Assault Missile x2828
      Sisters Combat Scanner Probe x8
      Scourge Rage Heavy Assault Missile x6803
      Core Scanner Probe I x8
      Multispectrum Shield Hardener II x1
      Ballistic Control System II x1
      Medium EM Shield Reinforcer II x1
      Mobile Depot x1
      Mobile Tractor Unit x1
      """

      expected_result = %{
        "fitting_name" => "Simulated Tengu Fitting",
        "ship" => "Tengu",
        "slots" => %{
          "low" => [
            %{"name" => "Ballistic Control System II"},
            %{"name" => "Ballistic Control System II"}
          ],
          "mid" => [
            %{"name" => "Republic Fleet Large Cap Battery"},
            %{"name" => "Pith B-Type Shield Boost Amplifier"},
            %{"name" => "Pith C-Type Large Shield Booster"},
            %{"name" => "Federation Navy 10MN Afterburner"},
            %{"name" => "Multispectrum Shield Hardener II"},
            %{"name" => "Warp Scrambler II"},
            %{"name" => "Stasis Webifier II"}
          ],
          "high" => [
            %{"name" => "Heavy Assault Missile Launcher II"},
            %{"name" => "Heavy Assault Missile Launcher II"},
            %{"name" => "Heavy Assault Missile Launcher II"},
            %{"name" => "Heavy Assault Missile Launcher II"},
            %{"name" => "Heavy Assault Missile Launcher II"},
            %{"name" => "Heavy Assault Missile Launcher II"},
            %{"name" => "Covert Ops Cloaking Device II"},
            %{"name" => "Expanded Probe Launcher I"}
          ],
          "rigs" => [
            %{"name" => "Medium Ancillary Current Router I"},
            %{"name" => "Medium EM Shield Reinforcer II"},
            %{"name" => "Medium Capacitor Control Circuit II"}
          ],
          "subsystems" => [
            %{"name" => "Tengu Core - Augmented Graviton Reactor"},
            %{"name" => "Tengu Defensive - Covert Reconfiguration"},
            %{"name" => "Tengu Offensive - Accelerated Ejection Bay"},
            %{"name" => "Tengu Propulsion - Fuel Catalyst"}
          ]
        },
        "cargo" => [
          %{"name" => "Guristas Nova Heavy Assault Missile", "quantity" => 1000},
          %{"name" => "Mjolnir Rage Heavy Assault Missile", "quantity" => 1500},
          %{"name" => "Scourge Javelin Heavy Assault Missile", "quantity" => 2828},
          %{"name" => "Sisters Combat Scanner Probe", "quantity" => 8},
          %{"name" => "Scourge Rage Heavy Assault Missile", "quantity" => 6803},
          %{"name" => "Core Scanner Probe I", "quantity" => 8},
          %{"name" => "Multispectrum Shield Hardener II", "quantity" => 1},
          %{"name" => "Ballistic Control System II", "quantity" => 1},
          %{"name" => "Medium EM Shield Reinforcer II", "quantity" => 1},
          %{"name" => "Mobile Depot", "quantity" => 1},
          %{"name" => "Mobile Tractor Unit", "quantity" => 1}
        ],
        "drones" => [],
        "boosters" => [
          %{"name" => "Agency 'Hardshell' TB5 Dose II"},
          %{"name" => "Improved Blue Pill Booster"}
        ]
      }

      assert EFTParser.parse(eft_text) == expected_result

    end
  end
end
