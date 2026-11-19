import matplotlib.pyplot as plt
import matplotlib.patches as patches

def draw_er_diagram():
    fig, ax = plt.subplots(figsize=(20, 13), dpi=300)
    fig.patch.set_facecolor('#0f172a')
    ax.set_facecolor('#0f172a')
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Color palette
    CARD_BG = '#1e293b'
    BORDER_COLOR = '#334155'
    HEADER_FACT = '#4f46e5'
    HEADER_DIM = '#0284c7'
    HEADER_ANALYSIS = '#0d9488'

    ax.text(50, 97, "MOBILE CATALOG DATABASE — ENTITY RELATIONSHIP (ER) DIAGRAM",
            ha='center', va='center', color='#ffffff', fontsize=17, fontweight='bold')
    ax.text(50, 94.5, "NMIMS Mumbai Academic Project | 10 Normalized Entities (3NF) | 980 Smartphone Models",
            ha='center', va='center', color='#94a3b8', fontsize=11)

    output_path = "docs/er_diagram/er_diagram.png"
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()

if __name__ == '__main__':
    draw_er_diagram()
