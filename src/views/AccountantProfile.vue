<script setup>
import Header from '@/components/Header.vue';
import Footer from '@/components/Footer.vue';
import { useRouter } from 'vue-router';
import { ref, onMounted } from 'vue';
import axios from 'axios';

const router = useRouter()
const profile = ref()

const isLoading = ref(true)

async function checkToken() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({ name: 'Login' })
        return
    }

    try {
        const response = await axios.get('http://localhost:8080/accountant/profile', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })

        profile.value = response.data
    } catch (error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({ name: 'Login' });
        }
        if (error.response?.status === 403) {
            router.push({name: 'Planes'})
        }
        else console.log(error)
    }

    isLoading.value = false
}

function goToRentalsList() {
    router.push({name: 'RentalsList'})
}

onMounted(() => {
    checkToken()
})
</script>

<template>
    <body class="page">
        <Header></Header>
        <main class="main" v-if="!isLoading">
            <div class="profile">
                <img src="/nano-banana-new-logo-bez-fona.png" alt="стандартное фото в профиле пилота" class="profile-photo">
                <div>
                    <h1 class="pilot-name">{{ profile.name }}</h1>
                    <span class="status-pilot">БУХГАЛТЕР</span>
                    <ul class="profile-information">
                        <li>
                            <span>Логин:</span>
                            <span>{{ profile.login }}</span>
                        </li>
                        <button class="balance-button" @click="goToRentalsList">Список аренд</button>
                    </ul>
                </div>
            </div>
        </main>
    </body>
    
    <Footer></Footer>
</template>

<style scoped>
.main {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 30px;
    margin-top: 50px;
    margin-bottom: 50px;
    font-size: 18px;
}

.profile {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 30px;
    width: 70%;
    min-height: 300px;
    border: 2px solid #808080;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
    border-radius: 12px;
    position: relative;
    overflow: hidden;
    background-image: url(/zadnii-fon-profile.jpg);
    background-position: center;
    background-size: cover;
}

.profile-photo {
    width: 100%;
    height: 100%;
    background-position: center;
    background-size: cover;
}

.pilot-name {
    text-align: center;
}

.status-pilot {
    display: block;
    text-align: center;
    text-transform: uppercase;
    font-size: 20px;
    font-weight: 600;
}

.profile-information {
    margin-top: 30px;
    display: flex;
    flex-direction: column;
    gap: 25px;
}

.profile-information li {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 0;
    padding-right: 15px;
    border-bottom: 2px dotted #ddd;
    position: relative;
}

.profile-information li span:first-child {
    font-weight: 600;
    color: #2c3e50;
    font-size: 18px;
    position: relative;
    padding-left: 25px;
}

.profile-information li span:first-child::before {
    content: '▶';
    position: absolute;
    left: 0;
    color: #1E90FF;
    font-size: 14px;
}

.profile-information li:nth-child(4) span:last-child {
    font-size: 24px;
    font-weight: 700;
    color: #27ae60;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.1);
}

.balance-button {
    width: fit-content;
    min-height: 45px;
    cursor: pointer;
    border: none;
    background-color: #1E90FF;
    color: #fff;
    border-radius: 8px;
    transition: all 0.3s ease;
    font-size: 18px;
    font-weight: 600;
    padding: 12px 30px;
}

.balance-button:hover {
    transform: scale(1.1);
}
</style>