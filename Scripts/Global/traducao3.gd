
extends Node

var texts := {
	"eng": {
		
		"APRESENTA": "[shake rate=20 level=6]A game presented by \n[color=#9c01d2]FINAL LEVEL STUDIO...[/color][/shake]",
		
		"TUTORIAL_1": "[wave]Use [img=24x24]res://Sprites/UI/botoes_setinhas.png[/img] / [bgcolor=#444444][color=#ffffff] WASD [/color][/bgcolor] to move,\nand [img=24x24]res://Sprites/UI/botao_X.png[/img] / [bgcolor=#444444][color=#ffffff] SPACE [/color][/bgcolor] to jump![/wave]",
		"TUTORIAL_1_2": "[wave]You can also double jump![/wave]",
		"TUTORIAL_2": "[wave]Use [img=20x20]res://Sprites/UI/botao_quadrado.png[/img] / [bgcolor=#444444][color=#ffffff] ENTER [/color][/bgcolor]\nto interact![/wave]",
		"TUTORIAL_3": "[wave]Hold [img=24x24]res://Sprites/UI/botao_r2.png[/img] / [bgcolor=#444444][color=#ffffff] RIGHT CLICK [/color][/bgcolor]\nto shoot![/wave]",
		"TUTORIAL_4": "[wave]Use [img=24x24]res://Sprites/UI/botao_l2.png[/img] / [bgcolor=#444444][color=#ffffff] SHIFT [/color][/bgcolor]\nto dodge![/wave]",
		"TUTORIAL_4_2": "[shake]Timing matters! Be precise![/shake]",
		"TUTORIAL_5": "[wave]Use these to restore your ammo:[/wave]",
		"TUTORIAL_6": "[wave]Use [img=24x24]res://Sprites/UI/botao_r1.png[/img] / [bgcolor=#444444][color=#ffffff] LEFT CLICK [/color][/bgcolor]\nto attack![/wave]",
		"TUTORIAL_7": "[wave amp=16 freq=2]Also use the Right Analog Stick\n/ [bgcolor=#444444][color=#ffffff] ↑ ↓ ← → [/color][/bgcolor]\nto look around![/wave]",
		"TUTORIAL_8": "[wave]That's it, just like that!",
		"TUTORIAL_9": "[wave]Good! This will help a lot.[/wave]",
		
		"PRESS_QUADRADO": "[center]PRESS [img=24x24]res://Sprites/UI/botao_quadrado.png[/img]",
		"TRANCADO": "THE DOOR IS LOCKED.",
		"AVISO_FITA": "[wave]You found a SECRET...",
	},

	"ptbr": {
		"APRESENTA": "[shake rate=20 level=6]Um jogo apresentado pela \n[color=#9c01d2]FINAL LEVEL STUDIO...[/color][/shake]",
		
		"TUTORIAL_1": "[wave]Use [img=24x24]res://Sprites/UI/botoes_setinhas.png[/img] / [bgcolor=#444444][color=#ffffff] WASD [/color][/bgcolor] para andar\ne [img=24x24]res://Sprites/UI/botao_X.png[/img] / [bgcolor=#444444][color=#ffffff] ESPAÇO [/color][/bgcolor] para pular![/wave]",
		"TUTORIAL_1_2": "[wave]Você também pode dar pulo duplo![/wave]",
		"TUTORIAL_2": "[wave]Use [img=20x20]res://Sprites/UI/botao_quadrado.png[/img] / [bgcolor=#444444][color=#ffffff] ENTER [/color][/bgcolor]\npara interagir![/wave]",
		"TUTORIAL_3": "[wave]Segure [img=24x24]res://Sprites/UI/botao_r2.png[/img] / [bgcolor=#444444][color=#ffffff] CLIQUE DIR. [/color][/bgcolor]\npara atirar![/wave]",
		"TUTORIAL_4": "[wave]Use [img=24x24]res://Sprites/UI/botao_l2.png[/img] / [bgcolor=#444444][color=#ffffff] SHIFT [/color][/bgcolor]\npara esquivar![/wave]",
		"TUTORIAL_4_2": "[shake]O timing é tudo! Seja preciso![/shake]",
		"TUTORIAL_5": "[wave]Munição é recarregada com esses itens:[/wave]",
		"TUTORIAL_6": "[wave]Use [img=24x24]res://Sprites/UI/botao_r1.png[/img] / [bgcolor=#444444][color=#ffffff] CLIQUE ESQ. [/color][/bgcolor]\npara atacar![/wave]",
		"TUTORIAL_7": "[wave amp=16 freq=2]Também use o Analógico Direito\n/ [bgcolor=#444444][color=#ffffff] ↑ ↓ ← → [/color][/bgcolor]\npara olhar em volta![/wave]",
		"TUTORIAL_8": "[wave]Isso, assim mesmo!",
		"TUTORIAL_9": "[wave]Boa! Isso vai te ajudar bastante.[/wave]",
		
		"PRESS_QUADRADO": "[center]PRESSIONE [img=24x24]res://Sprites/UI/botao_quadrado.png[/img]",
		"TRANCADO": "A PORTA ESTÁ TRANCADA.",
		"AVISO_FITA": "[wave]Você encontrou um SEGREDO..."
	}
}

func get_text(key: String) -> String:
	return texts.get(Global.lingua, {}).get(key, "[MISSING TUTORIAL TEXT: %s]" % key)
