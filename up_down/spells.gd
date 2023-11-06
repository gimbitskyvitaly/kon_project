extends Node

var missile_scene = load("res://bullet.tscn")

var elements = ['fire', 'air', 'water', 'earth']

var spell_tree = {
	'shield': cast_shield,
	'missile': cast_missile
}

var mana_costs = {
	'missile': 5
}

# for now: one element - one spell effect
var spell_effects = {
	'shield': {
		'fire': 'burn',
		'water': 'slowdown',
		'air': 'throwback'
	},
	'missile': {
		'fire': 'strike',
		'air': 'throwback'
	}
}

var default_spell_params = {
	'shield': {
		'fire': {
			'created': {'damage': 0.04},
			'removed': {'damage': 0.00}
		},
		'water': {
			'created': {}, # self reference required, processed separately
			'removed': {'slowdown_center': null}
		},
		'air': {
			'created': {}, # self reference required, processed separately
			'removed': {'global_position': null}
		}
	},
	'missile': {
		'fire': {
			'created': {'damage': 5.0},
#			'removed': {'damage': 0.00}
		},
		'air': {
			'created': {}, # self reference required, processed separately
			'removed': {'global_position': null}
		}
	}
}

# SHIELDS INFO

var element_colors = {
	'air': Color(1, 1, 1, 1),
	'fire': Color(1, 0, 0, 1),
	'water': Color(0, 0, 1, 1),
	'earth': Color(0, 0, 0, 0)
}


# ELEMENT EFFECTS

var element_effects = {
	'fire': {
		'burn': process_fire_burn_effect,
		'strike': process_fire_strike_effect
	},
	'water': {
		'slowdown': process_water_slowdown_effect
	},
	'air': {
		'throwback': process_air_throwback_effect
	}
}
	
func process_element_effect(element, effect, params):
	element_effects[element][effect].call(params)

func process_fire_burn_effect(params):
	var body = params['body']
	var damage = params['damage']
	body.burn_damage = damage
	
func process_fire_strike_effect(params):
	var body = params['body']
	var damage = params['damage']
	body.take_damage(damage)
	
func process_water_slowdown_effect(params):
	var body = params['body']
	var slowdown_center = params['slowdown_center']
	body.slowdown_center = slowdown_center
	
func process_air_throwback_effect(params):
	var body = params['body']
	var global_position = params['global_position']
	body.glob_pos_from_air_shield = global_position
	
func remove_spell_effects(spell_name, bodies, elements):
	for body in bodies:
		for element in elements:
			var effect = spell_effects[spell_name][element]
			var effect_removal_params = default_spell_params[spell_name][element]['removed']
			effect_removal_params['body'] = body
			process_element_effect(element, effect, effect_removal_params)
	
# SPELLS

func cast_spell(spell_name, element, params):
	if params.has('caster'): # TODO: add caster always
		var caster = params['caster']
		var spell_cost = mana_costs[spell_name]
		if caster.mana >= spell_cost:
			caster.spend_mana(spell_cost)
	spell_tree[spell_name].call(element, params)

func cast_shield(element, params):
	var shape = params['shape']
	var sprite = params['sprite']
	var prev_shield_element = sprite.get_meta('element')
	
	# replace 3rd arg with all elements
	remove_spell_effects('shield', params['bodies'], ['fire', 'water', 'air'])
	shape.disabled = !shape.disabled
	shape.disabled = !shape.disabled
	
	if !prev_shield_element or prev_shield_element == element:
		shape.disabled = !shape.disabled
		sprite.visible = !sprite.visible
	sprite.modulate = element_colors[element]
	sprite.set_meta('element', element if !shape.disabled else null)

func cast_missile(element, params):
	var target = params['target']
	var scene = params['scene']
	var caster = params['caster']
	var missile = missile_scene.instantiate()
	var dist_from_cust = 20
	var v = caster.global_position.direction_to(target)
	missile.position = caster.position + v * dist_from_cust
	missile.velocity = v
	missile.rotation = v.angle()
	missile.modulate = element_colors[element]
	missile.element = element
	scene.add_child(missile)
	

