const { onRequest } = require("firebase-functions/v2/https");
const { MercadoPagoConfig, Preference } = require("mercadopago");

// CONFIGURACIÓN DE MERCADO PAGO
// Reemplaza con tu Access Token real de Mercado Pago
const client = new MercadoPagoConfig({ 
    accessToken: 'APP_USR-3646103650065997-031520-6831bbe8c9d025be475bd74f1d2c33bc-622903312' 
});

exports.createPreference = onRequest({ cors: true }, async (req, res) => {
    try {
        const preference = new Preference(client);
        const data = req.body.data;

        const response = await preference.create({
            body: {
                items: [{
                    title: data.title || "Compra Eco Granel",
                    quantity: 1,
                    unit_price: Number(data.unit_price),
                    currency_id: 'COP'
                }],
                payer: {
                    email: data.payer_info.email
                },
                auto_return: "approved",
                back_urls: {
                    success: "https://www.google.com"
                }
            }
        });

        res.status(200).send({ data: { init_point: response.init_point } });
    } catch (error) {
        console.error("Error en MP:", error);
        res.status(500).send({ data: error });
    }
});