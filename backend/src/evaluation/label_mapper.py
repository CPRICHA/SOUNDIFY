YAMNET_TO_URBAN = {

    # =====================================================
    # General Categories
    # =====================================================

    "Animal": "dog_bark",
    "Domestic animals, pets": "dog_bark",

    "Vehicle": "engine_idling",
    "Motor vehicle (road)": "engine_idling",
    "Emergency vehicle": "siren",

    "Speech": "children_playing",

    "Alarm": "siren",

    "Tools": "drilling",

    "Noise": "drilling",

    "Fireworks": "gun_shot",

    "Inside, small room": "air_conditioner",

    "White noise": "air_conditioner",

    "Electric shaver, electric razor": "drilling",

    "Ratchet, pawl": "jackhammer",

    "Helicopter": "drilling",

    "Beatboxing": "street_music",

    "Silence": "gun_shot",

    # =====================================================
    # Air Conditioner
    # =====================================================

    "Air conditioning": "air_conditioner",

    # =====================================================
    # Car Horn
    # =====================================================

    "Vehicle horn, car horn, honking": "car_horn",
    "Car alarm": "car_horn",
    "Toot": "car_horn",

    # =====================================================
    # Children Playing
    # =====================================================

    "Children playing": "children_playing",
    "Children shouting": "children_playing",
    "Child speech, kid speaking": "children_playing",
    "Child singing": "children_playing",

    # =====================================================
    # Dog Bark
    # =====================================================

    "Dog": "dog_bark",
    "Bark": "dog_bark",
    "Bow-wow": "dog_bark",
    "Canidae, dogs, wolves": "dog_bark",
    "Growling": "dog_bark",
    "Whimper (dog)": "dog_bark",
    "Howl": "dog_bark",
    "Yip": "dog_bark",

    # =====================================================
    # Drilling
    # =====================================================

    "Drill": "drilling",
    "Dental drill, dentist's drill": "drilling",
    "Power tool": "drilling",

    # =====================================================
    # Engine Idling
    # =====================================================

    "Engine": "engine_idling",
    "Idling": "engine_idling",
    "Light engine (high frequency)": "engine_idling",
    "Medium engine (mid frequency)": "engine_idling",
    "Heavy engine (low frequency)": "engine_idling",
    "Engine starting": "engine_idling",
    "Engine knocking": "engine_idling",

    # =====================================================
    # Gun Shot
    # =====================================================

    "Gunshot, gunfire": "gun_shot",
    "Cap gun": "gun_shot",
    "Machine gun": "gun_shot",
    "Explosion": "gun_shot",
    "Boom": "gun_shot",

    # =====================================================
    # Jackhammer
    # =====================================================

    "Jackhammer": "jackhammer",
    "Hammer": "jackhammer",

    # =====================================================
    # Siren
    # =====================================================

    "Siren": "siren",
    "Police car (siren)": "siren",
    "Ambulance (siren)": "siren",
    "Fire engine, fire truck (siren)": "siren",
    "Civil defense siren": "siren",

    # =====================================================
    # Street Music
    # =====================================================

    "Music": "street_music",
    "Song": "street_music",
    "Background music": "street_music",
    "Pop music": "street_music",
    "Rock music": "street_music",
    "Hip hop music": "street_music",
    "Jazz": "street_music",
    "Classical music": "street_music",
    "Electronic music": "street_music",
}


def map_label(yamnet_label):
    """
    Maps a YAMNet AudioSet label to the closest
    UrbanSound8K class.
    """
    return YAMNET_TO_URBAN.get(yamnet_label, "unknown")