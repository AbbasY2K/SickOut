extends Node

var texts := {
	"eng": {
		"TUTORIAL_1": "[wave]Use [img=24x24]res://Sprites/UI/botoes_setinhas.png[/img] to move,\nand [img=24x24]res://Sprites/UI/botao_X.png[/img] to jump![/wave]",
		"TUTORIAL_1_2": "[wave]You can also double jump![/wave]",
		"TUTORIAL_2": "[wave]Use [img=20x20]res://Sprites/UI/botao_quadrado.png[/img] to interact![/wave]",
		"TUTORIAL_3": "[wave]Hold [img=24x24]res://Sprites/UI/botao_r2.png[/img]\nto shoot![/wave]",
		"TUTORIAL_4": "[wave]Use [img=24x24]res://Sprites/UI/botao_l2.png[/img] to dodge![/wave]",
		"TUTORIAL_4_2": "[shake]Timing matters! Be precise![/shake]",
		"TUTORIAL_5": "[wave]Use these to restore your ammo:[/wave]",
		"TUTORIAL_6": "[wave]Use [img=24x24]res://Sprites/UI/botao_r1.png[/img]\nto attack![/wave]",
		"TUTORIAL_7": "[wave amp=16 freq=2]Also use the Right Analog Stick to look around![/wave]",
		"TUTORIAL_8": "[wave]That's it, just like that!",
		"TUTORIAL_9": "[wave]Good! This will help a lot.[/wave]",
		
		"PRESS_QUADRADO": "[center]PRESS [img=24x24]res://Sprites/UI/botao_quadrado.png[/img]",
		"TRANCADO": "THE DOOR IS LOCKED."
	},

	"ptbr": {
		"TUTORIAL_1": "[wave]Use [img=24x24]res://Sprites/UI/botoes_setinhas.png[/img] para andar\ne [img=24x24]res://Sprites/UI/botao_X.png[/img] para pular![/wave]",
		"TUTORIAL_1_2": "[wave]Você também pode dar pulo duplo![/wave]",
		"TUTORIAL_2": "[wave]Use [img=20x20]res://Sprites/UI/botao_quadrado.png[/img] para interagir![/wave]",
		"TUTORIAL_3": "[wave]Segure [img=24x24]res://Sprites/UI/botao_r2.png[/img]\npara atirar![/wave]",
		"TUTORIAL_4": "[wave]Use [img=24x24]res://Sprites/UI/botao_l2.png[/img] para esquivar![/wave]",
		"TUTORIAL_4_2": "[shake]O timing é tudo! Seja preciso![/shake]",
		"TUTORIAL_5": "[wave]Munição é recarregada com esses itens:[/wave]",
		"TUTORIAL_6": "[wave]Use [img=24x24]res://Sprites/UI/botao_r1.png[/img]\npara atacar![/wave]",
		"TUTORIAL_7": "[wave amp=16 freq=2]Também use o Analógico Direito para olhar em volta!",
		"TUTORIAL_8": "[wave]Isso, assim mesmo!",
		"TUTORIAL_9": "[wave]Boa! Isso vai te ajudar bastante.[/wave]",
		
		"PRESS_QUADRADO": "[center]PRESSIONE [img=24x24]res://Sprites/UI/botao_quadrado.png[/img]",
		"TRANCADO": "A PORTA ESTÁ TRANCADA."
	}
}

func get_text(key: String) -> String:
	return texts.get(Global.lingua, {}).get(key, "[MISSING TUTORIAL TEXT: %s]" % key)
