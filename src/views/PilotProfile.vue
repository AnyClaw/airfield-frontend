<script setup>
import Header from '@/components/Header.vue';
import { useRouter } from 'vue-router';
import { jwtDecode } from 'jwt-decode';
import { ref, onMounted } from 'vue';

const token = localStorage.getItem('authToken')

const router = useRouter()
const claims = ref(null)

onMounted(() => {
    if (!token) {
        router.push({name: 'Login'})
        return
    }   

    claims.value = jwtDecode(token)
})
</script>

<template>
    <Header/>
    <div>{{ claims }}</div>
</template>

<style scoped>

</style>