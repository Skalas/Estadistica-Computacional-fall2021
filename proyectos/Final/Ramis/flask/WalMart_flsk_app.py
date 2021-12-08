# from flask import jsonify, request, Flask, url_for, json
import flask
import pickle
import sklearn
import numpy

#  --> Kaggle's Walmart Recruiting: Trip Type Classification

# Cargar Modelo para Problema de Aprendizaje Supervisado Multiclase
with open("modelo_lr_pkl", "rb") as f:
    model_loaded = pickle.load(f)

app = flask.Flask(__name__, template_folder='templates')

print("Black SwanA:", __name__)

@app.route('/wmclassifier', methods=['GET'])
def feeddata():
        return(flask.render_template('wmclassweb.html'))

@app.route('/wmclassifier', methods=['POST'])
def predict():
    array_inputs = numpy.array([flask.request.form['NumItems'],flask.request.form['Return'],
                                flask.request.form['1-HR PHOTO'],flask.request.form['ACCESSORIES'],
                                flask.request.form['AUTOMOTIVE'],flask.request.form['BAKERY'],
                                flask.request.form['BATH AND SHOWER'],
                                flask.request.form['BEAUTY'],flask.request.form['BEDDING'],
                                flask.request.form['BOOKS AND MAGAZINES'],flask.request.form['BOYS WEAR'],
                                flask.request.form['BRAS & SHAPEWEAR'],flask.request.form['CAMERAS AND SUPPLIES'],
                                flask.request.form['CANDY, TOBACCO, COOKIES'],flask.request.form['CELEBRATION'],
                                flask.request.form['COMM BREAD'],flask.request.form['CONCEPT STORES'],
                                flask.request.form['COOK AND DINE'],flask.request.form['DAIRY'],
                                flask.request.form['DSD GROCERY'],flask.request.form['ELECTRONICS'],
                                flask.request.form['FABRICS AND CRAFTS'],flask.request.form['FINANCIAL SERVICES'],
                                flask.request.form['FROZEN FOODS'],flask.request.form['FURNITURE'],
                                flask.request.form['GIRLS WEAR, 4-6X  AND 7-14'],flask.request.form['GROCERY DRY GOODS'],
                                flask.request.form['HARDWARE'],flask.request.form['HOME DECOR'],
                                flask.request.form['HOME MANAGEMENT'],flask.request.form['HORTICULTURE AND ACCESS'],
                                flask.request.form['HOUSEHOLD CHEMICALS/SUPP'],flask.request.form['HOUSEHOLD PAPER GOODS'],
                                flask.request.form['IMPULSE MERCHANDISE'],flask.request.form['INFANT APPAREL'],
                                flask.request.form['INFANT CONSUMABLE HARDLINES'],flask.request.form['JEWELRY AND SUNGLASSES'],
                                flask.request.form['LADIES SOCKS'],flask.request.form['LADIESWEAR'],
                                flask.request.form['LARGE HOUSEHOLD GOODS'],flask.request.form['LAWN AND GARDEN'],
                                flask.request.form['LIQUOR,WINE,BEER'],flask.request.form['MEDIA AND GAMING'],
                                flask.request.form['MEAT - FRESH & FROZEN'],
                                flask.request.form['MENSWEAR'],flask.request.form['OFFICE SUPPLIES'],
                                flask.request.form['OPTICAL - FRAMES'],flask.request.form['OPTICAL - LENSES'],
                                flask.request.form['OTHER DEPARTMENTS'],flask.request.form['PAINT AND ACCESSORIES'],
                                flask.request.form['PERSONAL CARE'],flask.request.form['PETS AND SUPPLIES'],
                                flask.request.form['PHARMACY OTC'],flask.request.form['PHARMACY RX'],
                                flask.request.form['PLAYERS AND ELECTRONICS'],flask.request.form['PLUS AND MATERNITY'],
                                flask.request.form['PRE PACKED DELI'],flask.request.form['PRODUCE'],
                                flask.request.form['SEAFOOD'],flask.request.form['SEASONAL'],
                                flask.request.form['SERVICE DELI'],flask.request.form['SHEER HOSIERY'],
                                flask.request.form['SHOES'],flask.request.form['SLEEPWEAR/FOUNDATIONS'],
                                flask.request.form['SPORTING GOODS'],
                                flask.request.form['SWIMWEAR/OUTERWEAR'],flask.request.form['TOYS'],
                                flask.request.form['WIRELESS'],
                                flask.request.form['1'],flask.request.form['2'],flask.request.form['3'],
                                flask.request.form['4'],flask.request.form['5'],flask.request.form['6'],
                                flask.request.form['7']]).reshape(-1,1).T
    res_val = model_loaded.predict(array_inputs.astype(int))
    return(flask.render_template('wmclassweb.html',triptype_val = res_val))
    
if __name__ == '__main__':
    # app.run(debug=True)
    app.run(host="0.0.0.0", debug=True, port=8080)


